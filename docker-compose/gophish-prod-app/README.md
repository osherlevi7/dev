# GoPhishing Campaign 

    > gophish application using golang
    > mySQL db for using the data from the compaign
    > nginx webapp proxy 
    > postfix email transfer agent



# Before Build the App 
* edit the nginx conf file and Dockerfile to contains the right conf for your domain name and cert.

### create the .env with the following stracture before build the app 
```bash
# Database
MYSQL_DATABASE= <DB NAME>
MYSQL_USER= <DB USER>
MYSQL_PASSWORD= <DB PASS>
MYSQL_ROOT_PASSWORD= <DB ROOT PASS>

# Postfix
MTP_HOST= <MTS SERVER>
MTP_PASS= <MTP PASS>
```
* Change the `server_name` in `/etc/nginx/config.conf` from `localhost` to **domain**

* Build the `docker-compose` 

```bash
    make build
```
* Run the `docker-compose`

```bash 
    make up 
```
* More `make` commands 

```bash
    make help 
```

# **Notice**

SSL configuration are built in on the dockerfile on the nginx dockerfile once we build the app.  

> Change the command to run with you domain.
