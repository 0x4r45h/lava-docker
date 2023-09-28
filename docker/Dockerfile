FROM golang:bullseye

RUN apt-get update && apt-get install -y jq bash nano git logrotate sed unzip wget curl coreutils
RUN go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0

ARG CONFIG_REPO_URL=https://github.com/lavanet/lava-config.git
ARG CONFIG_REPO_PATH=lava-config/testnet-2
ARG LAVAD_GENESIS_BIN=https://github.com/lavanet/lava/releases/download/v0.21.1.2/lavad-v0.21.1.2-linux-amd64
ARG LAVA_REPO_URL=https://github.com/lavanet/lava.git
ARG LAVA_REPO_TAG=v0.23.5

WORKDIR "/tmp"
RUN git clone $CONFIG_REPO_URL
RUN git clone --branch  $LAVA_REPO_TAG $LAVA_REPO_URL

RUN wget -O /tmp/lavad  $LAVAD_GENESIS_BIN
RUN mkdir -p "/root/.lava/config" "/root/.lava/cosmovisor/genesis/bin/"
COPY /tmp/$CONFIG_REPO_PATH/default_lavad_config_files/* /root/.lava/config/
COPY /tmp/$CONFIG_REPO_PATH/genesis_json/genesis.json /root/.lava/config/genesis.json
COPY /tmp/lavad /root/.lava/cosmovisor/genesis/bin/
RUN chmod +x /root/.lava/cosmovisor/genesis/bin/lavad
WORKDIR "/tmp/lava"
# make all instead of BINs
RUN make install-all
RUN rm -rf /tmp/*
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh
#ENV PATH="/go/bin:/root/.lava/cosmovisor/current/bin:$PATH"
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["cosmovisor --help"]