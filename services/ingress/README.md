# Example for generating a certificate and updating nginx

1.  Generate the .pem files (this example uses certbot and letsencrypt):
    ```
    sudo certbot certonly --manual --preferred-challenges=dns --email yourname@yourdomain.com --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d *.yourdomian.com
    ```
2.  Then add the fullchain.pem and the privkey.pem to the beyond-ingress/certs directory:
    ```
    beyond-ingress/certs
    ├── fullchain.pem
    └── privkey.pem
    ```
