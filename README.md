# Lava Dockerized

### Requirements
- Docker and Docker Compose (Tested on Linux only)

## Validator
to run a validator clone this repo on server and cd into it

copy environment file sample to .env and set your configs
```shell
cp .env.sample .env
```

### Initialize configs
follow the instructions to import your wallet, or backup newly generated account and public key
```shell
docker compose run --rm validator init
```
this will also create a new `priv_json_validator.json` file, if you want to import your previous validator copy it into the volume as follow :
1. inside the repository directory, create a folder called `backup_validator_keys`, then put your `priv_json_validator.json` and `node_key.json` inside it
2. run the copy helper command
```shell
./helpers.sh node:restore
```
otherwise make a backup from newly generated files and keep them safe:
```shell
./helpers.sh node:backup
```
### Run the Node in background
```shell
docker compose up -d validator
```

## Become a validator

### Request test token
get test tokens from faucet using your public address

### Run the validator instance

wait for your validator to catch up with the rest of network before you proceeding. you can check validator's current info by running this:
```shell
docker compose exec validator /opt/helpers.sh validator:sync-info
```
Wait until `catching_up` becomes `false` then proceed.
Verify that your account has funds in it in order to perform staking
```shell
docker compose exec validator /opt/helpers.sh wallet:balance
```
### Create Validator

```shell
docker compose exec validator /opt/helpers.sh validator:connect
```

