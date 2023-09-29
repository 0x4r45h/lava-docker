#!/bin/bash
LAVA_GENESIS_BINARY="/root/.lava/cosmovisor/genesis/bin/lavad --home /root/.lava"

init_function() {
  if [ -z "$ACCOUNT_NAME" ]; then
    echo "Error: ACCOUNT_NAME environment variable is not set or empty."
    exit 1
  fi
  output=$($LAVA_GENESIS_BINARY keys list)
  if echo "$output" | grep -q "$ACCOUNT_NAME"; then
    echo "Account '$ACCOUNT_NAME' already exists."
    $LAVA_GENESIS_BINARY keys show "$ACCOUNT_NAME"
  else
    echo "Account '$ACCOUNT_NAME' not found."
    echo "Would you like to recover a previous account using mnemonic keys? (Y/N)"
    while true; do
      read -p "Enter choice: " choice
      case "$choice" in
        [Yy])
          $LAVA_GENESIS_BINARY keys add "$ACCOUNT_NAME" --recover
          break
          ;;
        [Nn])
          $LAVA_GENESIS_BINARY keys add "$ACCOUNT_NAME"
          break
          ;;
        *)
          echo "Invalid choice. Please enter Y or N."
          ;;
      esac
    done
  fi

# Backup genesis.json
  mv /root/.lava/config/genesis.json /root/.lava/config/genesis.json.bak
  # Run lavad init command
  $LAVA_GENESIS_BINARY init $MONIKER_NAME > /dev/null 2>&1
  # Replace genesis.json with backed up file
  cp /root/.lava/config/genesis.json.bak /root/.lava/config/genesis.json
  # set chain id for testnet-2
  $LAVA_GENESIS_BINARY config chain-id lava-testnet-2
  # Print validator pubkey
  echo "Validator pubkey is : "
  $LAVA_GENESIS_BINARY tendermint show-validator
}

start_lavavisor() {
      file_path="/root/.lavavisor/config.yml"
      if [ ! -e  "$file_path" ]; then
        lavavisor init --auto-download --chain-id $CHAIN_ID --node $LAVA_NODE && lavavisor create-service $SERVICE_TYPE /rpc.yml --geolocation $GEO_LOCATION --from $ACCOUNT_NAME --log_level $LOG_LEVEL --keyring-backend test --chain-id $CHAIN_ID  --node $LAVA_NODE
      fi
        lavavisor start --chain-id $CHAIN_ID --node $LAVA_NODE
}
update_lavap() {
  while true; do
    lavavisor init --auto-download --chain-id $CHAIN_ID --node $LAVA_NODE ----directory /go/bin
    sleep 300 # every 5min
  done
}
main() {
  case "$1" in
    "init")
      init_function
      ;;
    "update-lavap-version")
      update_lavap
      ;;
    "start-node")
      cosmovisor start --home=/root/.lava --p2p.seeds $SEED_NODE
      ;;
    *)
      exec "$@"
      ;;
  esac
}

main "$@"
