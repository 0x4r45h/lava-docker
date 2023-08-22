#!/bin/bash

main() {
  case "$1" in
    "start")
      cosmovisor --home /root/.lava rpcprovider --node tcp://validator:26657  --geolocation 2 --from $ACCOUNT_NAME --chain-id "lava-testnet-1"
      ;;
    *)
      exec "$@"
      ;;
  esac
}

main "$@"
