FROM alpine:3.8
LABEL maintainer="joachim@teamwire.eu"

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        libc6-compat \
        libssh \
        msgpack-c \
        ncurses-libs \
        libevent \
        openssh-keygen

ADD backtrace.patch /backtrace.patch
ADD message.sh /message.sh
ADD tmate-server.sh /tmate-server.sh

RUN apk add --no-cache --virtual build-dependencies \
        build-base \
        ca-certificates \
        bash \
        wget \
        git \
        openssh \
        libc6-compat \
        automake \
        autoconf \
        zlib-dev \
        libevent-dev \
        msgpack-c-dev \
        ncurses-dev \
        libexecinfo-dev \
        libssh-dev && \
    mkdir /src && \
    git clone --depth=1 https://github.com/tmate-io/tmate-slave.git /src/tmate-server && \
    cd /src/tmate-server && \
    git apply /backtrace.patch && \
    cp create_keys.sh / && \
    sed -i -e '1s|#!/bin/bash|#!/bin/sh|' /create_keys.sh && \
    ./autogen.sh && \
    ./configure CFLAGS="-D_GNU_SOURCE" && \
    make -j && \
    cp tmate-slave /bin/tmate-slave && \
    apk del build-dependencies && \
    rm -rf /src

ENTRYPOINT ["/tmate-server.sh"]
