### create a external network called public

edit .env file add your root domain, also generate a user/password using command below and put in .env to access the dashboard
```shell
echo $(htpasswd -nB userfoo) | sed -e s/\\$/\\$\\$/g
```
- create `acme.json` file and set 600 file mode
```shell
touch ./acme.json && chmod 600 ./acme.json
```