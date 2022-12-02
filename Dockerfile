FROM alpine:edge as builder

ENV PREFIX_DIR=/usr/local
ENV HOME=/root
RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >>/etc/apk/repositories

RUN apk update && \
    apk upgrade

RUN apk update && \
        apk upgrade --available && \
        apk add --no-cache \
        openssl \
        ca-certificates \
        curl

RUN apk add --no-cache \
    wget \
    build-base \
    git \
    cmake \
    bison \
    flex \
    lcov@testing \
    cppcheck \
    cpputest \
    autoconf \
    automake \
    libtool \
    libdnet-dev \
    libpcap-dev \
    libtirpc-dev \
    luajit-dev \
    libressl-dev \
    zlib-dev \
    pcre-dev \
    libuuid \
    xz-dev \
    flex

RUN mkdir /usr/include/linux && \
    ln -s /usr/include/unistd.h /usr/include/linux/unistd.h && \
    ln -s /usr/include/unistd.h /usr/include/sys/unistd.h

WORKDIR $HOME
RUN wget https://download.open-mpi.org/release/hwloc/v2.0/hwloc-2.0.3.tar.gz &&\
    tar zxvf hwloc-2.0.3.tar.gz
WORKDIR $HOME/hwloc-2.0.3
RUN ./configure --prefix=${PREFIX_DIR} && \
    make && \
    make install


WORKDIR $HOME
RUN git clone https://github.com/snort3/libdaq.git
WORKDIR $HOME/libdaq
RUN ./bootstrap && \
    ./configure && make && \
    make install


WORKDIR $HOME
RUN git clone https://github.com/snort3/snort3.git

WORKDIR $HOME/snort3
RUN apk add cmake flex flex-dev
RUN ./configure_cmake.sh \
    --prefix=${PREFIX_DIR} \
    --enable-unit-tests

WORKDIR $HOME/snort3/build
    ./bootstrap && \
    ./configure && make && \
    make install
RUN make VERBOSE=1
RUN make check && \
    make install

FROM alpine:edge

ENV PREFIX_DIR=/usr/local
WORKDIR ${PREFIX_DIR}

RUN apk upgrade

RUN apk add --no-cache  \
    libdnet \
    luajit \
    libressl \
    libpcap \
    pcre \
    libtirpc \
    musl \
    libstdc++ \
    libuuid \
    zlib \
    xz

COPY --from=builder ${PREFIX_DIR}/etc/ ${PREFIX_DIR}/etc/
COPY --from=builder ${PREFIX_DIR}/lib/ ${PREFIX_DIR}/lib/
COPY --from=builder ${PREFIX_DIR}/bin/ ${PREFIX_DIR}/bin/
COPY --from=builder ${PREFIX_DIR}/include ${PREFIX_DIR}/include
COPY --from=builder ${PREFIX_DIR}/share/ ${PREFIX_DIR}/share/



WORKDIR /
RUN snort --version

