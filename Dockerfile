FROM ubuntu:20.04

RUN set -e && \
    apt-get update -q -y --no-install-recommends && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -q -y --no-install-recommends \
        git \
        build-essential \
        ca-certificates \
        cmake \
        libuv1-dev \
        libzmq3-dev \
        libsodium-dev \
        libpgm-dev \
        libnorm-dev \
        libgss-dev \
        libcurl4-openssl-dev

ADD . /usr/src/n2pool
WORKDIR /usr/src/n2pool
RUN git submodule update --init --recursive && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc)

# ---

FROM ubuntu:20.04
COPY --from=0 /usr/src/n2pool/build/n2pool /

RUN set -e && \
    apt-get update -q -y --no-install-recommends && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -q -y --no-install-recommends \
    libzmq5 \
    libuv1 \
    libcurl4 \
      && \
    apt-get clean

RUN groupadd -r n2pool -g 1000 && \
    useradd -u 1000 -r -g n2pool -s /sbin/nologin -c "n2pool user" n2pool
RUN mkdir -p /home/n2pool/.n2pool && \
    chown n2pool.n2pool /home/n2pool /home/n2pool/.n2pool
USER n2pool

EXPOSE 3333
EXPOSE 41518
EXPOSE 41519

VOLUME /home/n2pool/.n2pool

WORKDIR /home/n2pool/.n2pool
ENTRYPOINT ["/n2pool"]
