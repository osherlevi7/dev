# GoPhishing Campaign 

    > gophish application using golang - 3333 8080
    > mySQL db for using the data from the campaign - 3306
    > nginx webapp proxy - 80 443
    > postfix email transfer agent - 25
    > adminer for the admin server management - 9000



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

SSL certificate is manged by Certbot package, run it on the container after exec interactively session is created, copy this certificates to the local nginx directory and rebuild the app. 

```bash
    certbot --nginx
```



