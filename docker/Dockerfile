FROM golang:bullseye as builder

RUN apt-get update && apt-get install -y curl jq bash nano git unzip wget coreutils

ARG REPO_URL=https://github.com/lavanet/lava-config.git
ARG REPO_PATH=lava-config/testnet-2

WORKDIR "/tmp"
RUN git clone $REPO_URL
RUN mkdir -p "/tmp/repo" && mv $REPO_PATH/* /tmp/repo

RUN go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0
# Download the genesis binary
RUN wget -O /tmp/lavad  https://github.com/lavanet/lava/releases/download/v0.21.1.2/lavad-v0.21.1.2-linux-amd64

FROM debian:stable-20230109-slim
RUN apt-get update && apt-get install -y curl jq bash nano git logrotate sed wget curl coreutils

RUN mkdir -p "/root/.lava/config" && mkdir -p "/root/.lava/cosmovisor/genesis/bin/"
COPY --from=builder /tmp/repo/default_lavad_config_files/* /root/.lava/config/
COPY --from=builder /tmp/repo/genesis_json/genesis.json /root/.lava/config/genesis.json
COPY --from=builder /go/bin/cosmovisor /usr/local/bin/cosmovisor
COPY --from=builder /tmp/lavad /root/.lava/cosmovisor/genesis/bin/
RUN chmod +x /root/.lava/cosmovisor/genesis/bin/lavad
RUN mkdir -p /usr/local/bin
COPY entrypoint.sh /opt/entrypoint.sh
COPY lavad-wrapper.sh /usr/local/bin/lavad
RUN chmod +x /opt/entrypoint.sh
RUN chmod +x /usr/local/bin/lavad
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["cosmovisor --help"]