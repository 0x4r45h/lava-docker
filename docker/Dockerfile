FROM golang:bullseye

# Install essential tools in a single layer
RUN apt-get update && apt-get install -y \
    jq bash nano git logrotate sed unzip wget curl coreutils inotify-tools supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Go binary and clean up Go cache
RUN go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0

# Define build arguments
ARG CONFIG_REPO_URL=https://github.com/lavanet/lava-config.git
ARG CONFIG_REPO_PATH=lava-config/testnet-2
ARG LAVAD_GENESIS_BIN=https://github.com/lavanet/lava/releases/download/v0.21.1.2/lavad-v0.21.1.2-linux-amd64
ARG LAVA_REPO_URL=https://github.com/lavanet/lava.git
ARG LAVA_REPO_TAG=v0.23.5

# Set the working directory
WORKDIR /tmp

# Clone the config repository and lava repository in a single layer
RUN git clone $CONFIG_REPO_URL && git clone --branch $LAVA_REPO_TAG $LAVA_REPO_URL

# Download the lavad binary and set up lava config
RUN wget -O /tmp/lavad $LAVAD_GENESIS_BIN \
    && mkdir -p "/root/.lava/config" "/root/.lava/cosmovisor/genesis/bin/" \
    && cp -rp /tmp/$CONFIG_REPO_PATH/default_lavad_config_files/ /root/.lava/config/ \
    && cp /tmp/$CONFIG_REPO_PATH/genesis_json/genesis.json /root/.lava/config/genesis.json \
    && mv /tmp/lavad /root/.lava/cosmovisor/genesis/bin/ \
    && chmod +x /root/.lava/cosmovisor/genesis/bin/lavad

# Set the working directory for building lava
WORKDIR /tmp/lava

# Build and install lava
RUN make install-all

# Clean up temporary files
RUN rm -rf /tmp/*

# Copy entrypoint script and supervisor configuration
COPY entrypoint.sh /opt/entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make the entrypoint script executable
RUN chmod +x /opt/entrypoint.sh

# Set the PATH to include cosmovisor binaries
ENV PATH="/root/.lava/cosmovisor/current/bin:$PATH"

# Set the working directory
WORKDIR /root

# Copy watcher script
COPY watcher.sh watcher.sh
RUN chmod +x watcher.sh

# Define the entrypoint and default command
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["cosmovisor", "--help"]
