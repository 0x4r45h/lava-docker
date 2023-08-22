#!/bin/bash

LAVA_CURRENT_BINARY="/root/.lava/cosmovisor/current/bin/lavad --home /root/.lava"

set -e

_get_wallet_balance() {
  WALLET_ADDRESS=$($LAVA_CURRENT_BINARY keys show -a $ACCOUNT_NAME)
  $LAVA_CURRENT_BINARY query \
      bank balances \
      $WALLET_ADDRESS \
      --denom ulava
}
_validator_connect() {
$LAVA_CURRENT_BINARY tx staking create-validator \
    --amount="10000ulava" \
    --pubkey=$($LAVA_CURRENT_BINARY tendermint show-validator) \
    --moniker=$MONIKER_NAME \
    --chain-id=lava-testnet-1 \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="10000" \
    --gas="auto" \
    --gas-adjustment="1.5" \
    --gas-prices="0.05ulava" \
    --home="/root/.lava/" \
    --from=$ACCOUNT_NAME
}

_validator_unjail() {
$LAVA_CURRENT_BINARY tx slashing unjail \
    --chain-id=lava-testnet-1 \
    --gas="auto" \
    --gas-adjustment="1.5" \
    --gas-prices="0.05ulava" \
    --home="/root/.lava/" \
    --from=$ACCOUNT_NAME
}
_vote() {
$LAVA_CURRENT_BINARY tx gov vote $2 $3\
    --chain-id=lava-testnet-1 \
    --gas="auto" \
    --gas-adjustment="1.5" \
    --gas-prices="0.05ulava" \
    --home="/root/.lava/" \
    --from=$ACCOUNT_NAME
}

_delegate_to_validator() {
  # first argument is celestiavaloper address of validator and second is the amount e.g 1000000utia
$LAVA_CURRENT_BINARY-appd tx staking delegate \
    $2 $3 \
    --chain-id=lava-testnet-1 \
    --gas="auto" \
    --gas-adjustment="1.5" \
    --gas-prices="0.05ulava" \
    --home="/root/.lava/" \
    --from=$ACCOUNT_NAME
}
_getNodeValoperAddress() {
  $LAVA_CURRENT_BINARY keys show $VALIDATOR_WALLET_NAME --bech val -a
}

if [ "$1" = 'wallet:balance' ]; then
  _get_wallet_balance
elif [ "$1" = 'node:backup' ]; then
  mkdir -p ./backup_validator_keys
  docker run --rm \
  -v lava-docker_lava:/src \
  -v $(pwd)/backup_validator_keys:/dst \
  busybox sh -c "cp /src/config/node_key.json /src/config/priv_validator_key.json /dst/"

elif [ "$1" = 'node:restore' ]; then
    docker run --rm \
    -v lava-docker_lava:/dst \
    -v $(pwd)/backup_validator_keys:/src \
    busybox sh -c "cp /src/node_key.json /src/priv_validator_key.json /dst/config/"
elif [ "$1" = 'node:valoper' ]; then
  _getNodeValoperAddress
elif [ "$1" = 'validator:connect' ]; then
  _validator_connect
elif [ "$1" = 'validator:unjail' ]; then
  _validator_unjail
elif [ "$1" = 'validator:delegate' ]; then
  _delegate_to_validator "$@"
elif [ "$1" = 'validator:vote' ]; then
  _vote "$@"
elif [ "$1" = 'validator:sync-info' ]; then
  $LAVA_CURRENT_BINARY status | jq .SyncInfo
else
  echo "bad command"
fi
