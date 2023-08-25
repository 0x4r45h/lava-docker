To add more providers, copy this clone this lava directory with a new name, modify `RPC_CONTAINER_LABEL` and `RPC_URL` in .env file
Set desired configs in `rpcprovider.yml` file then run:    
```bash
docker compose up -d
```
That's it. your rpc node is up and running, fully isolated from other process. traefik will automatically detect this container and 
routes all traffic from `RPC_URL` to this container. just don't forget stake lava token your provider.

### Run lavad commands 
Generally, to run any `lavad` commands, inside the each provider directory prefix it with this :
```bash
docker compose exec lava [command args]
```
for example to test lava rpc:
```bash
docker compose exec lava test rpcprovider --from foo --endpoints "lava.example.com:443,LAV1"
```
