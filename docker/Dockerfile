FROM golang:1.21.2-bullseye as builder

RUN apt-get update && apt-get install -y jq bash git sed unzip wget curl coreutils
RUN go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0

ARG CONFIG_REPO_URL=https://github.com/lavanet/lava-config.git
ARG CONFIG_REPO_PATH=lava-config/testnet-2
ARG LAVAD_GENESIS_BIN=https://github.com/lavanet/lava/releases/download/v0.21.1.2/lavad-v0.21.1.2-linux-amd64
ARG LAVA_REPO_URL=https://github.com/lavanet/lava.git
ARG LAVA_REPO_TAG=v0.23.5

WORKDIR "/tmp"
RUN git clone $CONFIG_REPO_URL
RUN git clone --branch  $LAVA_REPO_TAG $LAVA_REPO_URL
RUN mkdir -p "/tmp/conf_repo" && mv $CONFIG_REPO_PATH/* /tmp/conf_repo

RUN wget -O /tmp/lavad  $LAVAD_GENESIS_BIN
WORKDIR "/tmp/lava"
# make all instead of BINs
RUN make install-all
# Remove the lavad binary to always use latest binary in path cosmovisor/current/bin
RUN rm /go/bin/lavad

#final image
FROM golang:1.21.2-bullseye
RUN apt-get update && apt-get install -y \
    jq bash nano git logrotate sed unzip wget curl coreutils inotify-tools supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "/root/.lava/config" && mkdir -p "/root/.lava/cosmovisor/genesis/bin/"
COPY --from=builder /tmp/conf_repo/default_lavad_config_files/* /root/.lava/config/
COPY --from=builder /tmp/conf_repo/genesis_json/genesis.json /root/.lava/config/genesis.json
COPY --from=builder /go/bin/* /go/bin/
COPY --from=builder /tmp/lavad /root/.lava/cosmovisor/genesis/bin/
COPY entrypoint.sh /opt/entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY watcher.sh /root/watcher.sh
RUN chmod +x /opt/entrypoint.sh /root/.lava/cosmovisor/genesis/bin/lavad /root/watcher.sh
ENV PATH="/root/.lava/cosmovisor/current/bin:$PATH"
WORKDIR "/root"
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["cosmovisor --help"]