#!/bin/bash

set -e

_get_wallet_balance() {
  WALLET_ADDRESS=$(lavad keys show -a $ACCOUNT_NAME)
  lavad query \
      bank balances \
      $WALLET_ADDRESS \
      --denom ulava
}
_validator_connect() {
lavad tx staking create-validator \
    --amount="50000000ulava" \
    --pubkey=$(lavad tendermint show-validator --home="$HOME/.lava/") \
    --moniker=$MONIKER_NAME \
    --chain-id=lava-testnet-1 \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="10000" \
    --gas="auto" \
    --gas-prices="0.05ulava" \
    --gas-adjustment="1.5" \
    --fees="1800utia" \
    --home="$HOME/.lava/" \
    --from=$ACCOUNT_NAME
}
_verify_validator_setup() {
block_time=60
# Check that the validator node is registered and staked
validator_pubkey=$(lavad tendermint show-validator | jq .key | tr -d '"')

lavad q staking validators | grep $validator_pubkey

# Check the voting power of your validator node - please allow 30-60 seconds for the output to be updated
sleep $block_time
lavad status | jq .ValidatorInfo.VotingPower | tr -d '"'
# Output should be > 0
}

if [ "$1" = 'wallet:balance' ]; then
  _get_wallet_balance
elif [ "$1" = 'validator:connect' ]; then
  _validator_connect
elif [ "$1" = 'validator:verify-setup' ]; then
  _verify_validator_setup
elif [ "$1" = 'validator:sync-info' ]; then
  lavad status | jq .SyncInfo
else
  echo "bad command"
fi
