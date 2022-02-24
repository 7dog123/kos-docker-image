FROM ubuntu:20.04 as build

ENV DEBIAN_FRONTEND=noninteractive

ARG INSTALL_DIR="/opt/toolchains/dc"
ARG KOS="$INSTALL_DIR/kos"
ARG PORTS="$INSTALL_DIR/kos-ports"

RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install build-essential texinfo libjpeg-dev \
    libpng-dev libelf-dev git subversion python curl \
    make automake autoconf autotools-dev wget && \
    apt-get autoclean

RUN mkdir -p "$INSTALL_DIR" && \
    git clone https://github.com/7dog123/KallistiOS "$KOS" && \
    git clone --recursive https://github.com/KallistiOS/kos-ports  "$PORTS"

RUN cd "$KOS/utils/dc-chain" &&  cp -r config.mk.testing.sample config.mk && \
    ./download.sh && ./unpack.sh && make patch && make build && make gdb && \
    ./cleanup.sh

RUN cd "$KOS" && cp -r "$KOS/doc/environ.sh.sample" "$KOS/environ.sh" && \
    chmod 755 *sh && . "$KOS/environ.sh" && make && . "$PORTS/utils/build-all.sh" && \
    cp -r  "$KOS/environ.sh" /etc/profile.d/

FROM scratch
COPY --from=build / /
