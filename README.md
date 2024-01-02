# Lava Dockerized

### Requirements
- Docker and Docker Compose (Tested on Linux only)
---
## Initialize settings

Create required external network and volume, which will be shared between different instances of nodes and providers
```shell
docker network create lava && docker network create public && docker volume create lava && docker volume create lava_binaries
```
Create acme.json file to store certificates   
```shell
touch traefik/acme.json && chmod 600 traefik/acme.json
```
Copy environment file sample to .env and set your configs.   
*Most users only need to edit `ACCOUNT_NAME` and `MONIKER_NAME`*
```shell
cp .env.sample .env
```
run below command and follow the instructions to import your wallet or create a new one.   
if you intend to create a new wallet, you keys will be displayed on screen **only one time**!   
**Don't forget to backup your newly generated account keys. Store it somewhere safe**
```shell
docker compose run --rm validator init
```
this will also create a new `priv_json_validator.json` file, if you want to import your previous validator copy it into the volume as follow :
1. inside the repository directory, create a folder called `backup_validator_keys`, then put your `priv_json_validator.json` and `node_key.json` inside it
2. run the copy helper command
```shell
./helpers.sh node:restore
```
otherwise **make a backup from newly generated files and keep them safe**     

**THESE KEYS CANNOT BE RESTORED USING MNEMONIC** so make a backup from these too
```shell
./helpers.sh node:backup
```
---
### A note on running `lavad` and `lavap` commands
Generally, to run any `lavad` or `lavap` commands, prefix it like this:
```bash
docker compose exec [service name] [lavad or lavap] [command args]
```
where service name can be either `validator` or `rpcprovider`. based on which docker-compose.yml file you are working with

for example to test our lava rpc using our own node, inside the rpc provider directory:
```bash
cd providers/lava
docker compose exec rpcprovider lavap test rpcprovider --node tcp://validator:26657 --from foo --endpoints "lava.example.com:443,LAV1"
```
---

# Run a Node / Validator
To a run node inside root directory of project, run this:
```shell
docker compose up -d validator
```
check logs
```shell
docker compose logs -f --tail 300 validator
```

## Become a validator

### Request test token
get test tokens from faucet using your public address

### Setup Validator

Wait for your node to catch up with the rest of network before you proceeding. you can check validator's current info by running this:
```shell
docker compose exec validator /opt/helpers.sh validator:sync-info
```
When `catching_up` became `false` then proceed.   

Verify that your account has funds in it in order to perform staking
```shell
docker compose exec validator /opt/helpers.sh wallet:balance
```
Sign a transaction to become a validator
```shell
docker compose exec validator /opt/helpers.sh validator:connect
```

#### Delegate to validator
first get the valoper address:
```shell
docker compose exec validator /opt/helpers.sh node:valoper
```
then use the valoper address and amount in ulava , e.g to delegate 325ulava:
```shell
docker compose exec validator /opt/helpers.sh validator:delegate VALOPER_ADDRESS_HERE "325ulava"

```
---

# Run RPC Providers

### Lavavisor
Each RPC container is managed by `lavavisor pod` , so it automatically updates the underlying `lavap` binary
    
### Run Providers/Consumers
**WARNING** I didn't test Consumer yet. maybe it doesn't work    
   

---
Each directory inside the providers directory represents only ONE rpc service. lava provider included by default.    

copy `.env.sample` to `.env` modify `RPC_CONTAINER_LABEL` and `RPC_URL`, `ACCOUNT_NAME` in .env file
also if you are running a node using this repository, leave `LAVA_NODE` as it is, otherwise set public node url.   

**IMPORTANT**   
The given `rpc.yml` example files assumes you are running you own lava node. if you are not running your own node, make sure to change all **node_urls** in `rpc.yml` to a public node url

```shell
cd providers/lava
cp .env.sample .env
```
Set desired configs in `rpc.yml` file then run:
```bash
docker compose up -d
```
That's it. your rpc provider is up and running, fully isolated from other process. traefik will automatically detect this container and generates a certificate using lets encrypt and
routes all traffic from `RPC_URL` to this container. just don't forget stake lava token your provider. for example to stake for lava provider :    
```shell
docker compose exec rpcprovider lavap --node tcp://validator:26657 tx pairing stake-provider LAV1 50000000000ulava "lava.example.com:443,2" 2 --from ACCOUNT_NAME_HERE  --provider-moniker MONIKER_HERE --gas-adjustment 1.5 --gas auto --gas-prices 0.0001ulava
```

To test your provider :
```shell
docker compose exec rpcprovider lavap test rpcprovider --node tcp://validator:26657 --from ACCOUNT_NAME_HERE --endpoints "lava.example.com:443,LAV1"
```
### Add more providers
To add more providers/consumers, clone this lava directory with a new name. repeat the same steps

