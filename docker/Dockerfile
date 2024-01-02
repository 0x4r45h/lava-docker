FROM golang:1.21.2-bullseye as builder

RUN apt-get update && apt-get install -y jq bash git sed unzip wget curl coreutils
RUN go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0

ARG CONFIG_REPO_URL=https://github.com/lavanet/lava-config.git
ARG CONFIG_REPO_PATH=lava-config/testnet-2
ARG LAVA_REPO_URL=https://github.com/lavanet/lava.git
ARG LAVA_REPO_TAG=v0.32.0

WORKDIR "/tmp"
RUN git clone $CONFIG_REPO_URL
RUN git clone --branch  $LAVA_REPO_TAG $LAVA_REPO_URL
RUN mkdir -p "/tmp/conf_repo" && mv $CONFIG_REPO_PATH/* /tmp/conf_repo

WORKDIR "/tmp/lava"
# install lavad, lavap, lavavisor
RUN make install-all

#final image
FROM golang:1.21.2-bullseye
RUN apt-get update && apt-get install -y \
    jq bash nano git logrotate sed unzip wget curl coreutils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "/root/.lava/config" && mkdir -p "/root/.lava/cosmovisor/genesis/bin/"
COPY --from=builder /tmp/conf_repo/default_lavad_config_files/* /root/.lava/config/
COPY --from=builder /tmp/conf_repo/genesis_json/genesis.json /root/.lava/config/genesis.json
COPY --from=builder /go/bin/lavavisor /go/bin/
COPY --from=builder /go/bin/cosmovisor /go/bin/
COPY --from=builder /go/bin/lavad /root/.lava/cosmovisor/genesis/bin/
# a helper wrapper to proxy lavap commands to the latest version of lavap
COPY lavap_latest.sh /bin/lavap
COPY entrypoint.sh /opt/entrypoint.sh
COPY helpers.sh /opt/helpers.sh

RUN chmod +x /opt/entrypoint.sh /root/.lava/cosmovisor/genesis/bin/lavad /bin/lavap
ENV PATH="/root/.lava/cosmovisor/current/bin:$PATH"
WORKDIR "/root"
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["cosmovisor --help"]