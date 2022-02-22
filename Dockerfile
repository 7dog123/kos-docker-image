FROM ubuntu:20.04 as build

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install build-essential texinfo libjpeg-dev \
    libpng-dev libelf-dev git subversion python curl \
    make automake autoconf autotools-dev && \
    apt-get autoclean

RUN mkdir -p /opt/toolchains/dc/ && cd /opt/toolchains/dc/ && \
    git clone git://git.code.sf.net/p/cadcdev/kallistios kos && \
    git clone git://git.code.sf.net/p/cadcdev/kos-ports && \
    cp config.mk.stable.sample config.mk && \
    ./download.sh && ./unpack.sh && make patch && make build && make gdb && ./cleanup.sh

RUN cp -r /opt/toolchains/dc/doc/environ.sh.sample /opt/toolchains/dc/environ.sh && \
    cd /opt/toolchains/dc && chmod 755 environ.sh && ./environ.sh && make && \
    cd /opt/toolchains/dc/kos-ports && ./utils/build-all.sh

FROM scratch
COPY --from=build / /
