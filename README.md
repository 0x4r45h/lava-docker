# Lava Dockerized

### Requirements
- Docker and Docker Compose (Tested on Linux only)

#### Initialize external volumes and networks
create required external network and volume, which will be shared between different instances of nodes and providers
```shell
docker network create lava && docker network create public && docker volume create lava
```
create acme.json file to store certificates   
```shell
touch traefik/acme.json && chmod 600 traefik/acme.json
```   
## Traefik 
we use traefik as reverse proxy. it also manages certificates seamlessly.    
insert your email (a valid email address or no cert will be generated) inside `traefik.toml` file under `certificatesResolvers.httpresolver.acme`, then run traefik instance:    
```shell
docker compose -f traefik/docker-compose.yml up -d
```

## Validator
to run a validator clone this repo on server and cd into it

copy environment file sample to .env and set your configs
```shell
cp .env.sample .env
```

### Initialize settings

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

### Run lavad commands
Generally, to run any `lavad` commands, prefix it like this:
```bash
docker compose exec [service name] lavad [command args]
```
where service name can be validator or rpcprovider. based on which docker-compose.yml file you are working with

for example to test lava rpc using our validator service as node, inside rpc provider directory:
```bash
docker compose exec rpcprovider lavad test rpcprovider tcp://validator:26657 --from foo --endpoints "lava.example.com:443,LAV1"
```

## Become a validator

### Request test token
get test tokens from faucet using your public address

### Setup Validator

wait for your node to catch up with the rest of network before you proceeding. you can check validator's current info by running this:
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
## Become RPC Provider
Each directory inside the providers directory represents and rpc service. lava included by default.    
copy `.env.sample` to `.env` modify `RPC_CONTAINER_LABEL` and `RPC_URL` in .env file
Set desired configs in `rpcprovider.yml` file then run:
```bash
docker compose up -d
```
That's it. your rpc node is up and running, fully isolated from other process. traefik will automatically detect this container and
routes all traffic from `RPC_URL` to this container. just don't forget stake lava token your provider.
### Add more providers
To add more providers, clone this lava directory with a new name. repeat the same steps

