# Lava Dockerized

### Requirements
- Docker and Docker Compose (Tested on Linux only)



## Initialize configs
copy `.env.sample` to `.env` then change the `ACCOUNT_NAME`, `MONIKER_NAME`or any other settings on the `.env` file
```shell
cp .env.sample .env
```

Run this command and follow the onscreen instructions to whether create a new account, or import an existing account.
**ATTENTION**:If you are creating a new account don't forget to back up mnemonic keys in a safe place!

```shell
docker compose run --rm node init
```


## Run the node
By running the following command your node starts syncing with blockchain in the background
```shell
docker compose up -d node
```
you can check logs like:
```shell
docker compose logs -f --tail 100 node
```


## Run the node
By running the following command your node starts syncing with blockchain in the background 
```shell
docker compose up -d node
```
you can check logs like:
```shell
docker compose logs -f --tail 100 node
```

this will also always create a new consensus key, whether you create a new account or import your own account. `priv_json_validator.json` file, if you want to import your previous validator copy it into the volume as follow :
1. inside the repository directory, create a folder called `backup_validator_keys`, then put your `priv_json_validator.json` and `node_key.json` inside it
2. run the copy helper command
```shell
./helpers.sh node:restore
```
otherwise make a backup from newly generated files and keep them safe:
```shell
./helpers.sh node:backup
```

## Validator


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

### Delegate to validator
first get the valoper address:
```shell
docker compose exec validator /opt/helpers.sh node:valoper
```
then use the valoper address and amount in ulava , e.g to delegate 325ulava:
```shell
docker compose exec validator /opt/helpers.sh validator:delegate VALOPER_ADDRESS_HERE "325ulava"

```


