#!/bin/bash

main() {
  case "$1" in
    "start")
      cosmovisor --home /root/.lava rpcprovider --node $LAVA_NODE  --geolocation 2 --from $ACCOUNT_NAME --chain-id "lava-testnet-2"
      ;;
    *)
      exec "$@"
      ;;
  esac
}

main "$@"
