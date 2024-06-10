
# TRAEFIK + LET ENCRYPT SSL
#### Add Treafik for the cluster 
```sh
    helm repo add traefik https://helm.traefik.io/traefik
    helm repo update 
    kubectl create namespace traefik
```
#### Modifay the values file so the installation will point to the LB IP 
```sh
    vim traefik/values.yaml
    helm install --namespace=traefik traefik traefik/traefik --values=values.yaml
```
# Treafik Dashboard 
#### Headers - the traefik headers for the middleware

This code snippet is defining a Traefik middleware that adds default headers to HTTP responses.
The headers being added include browserXssFilter, contentTypeNosniff, forceSTSHeader, stsIncludeSubdomains, stsPreload, stsSeconds, customFrameOptionsValue, and customRequestHeaders.
The middleware is named "default-headers" and is specified to be used in the "default" namespace.

```sh
    kubectl apply -f default-headers.yaml
    kubectl get middleware
```
#### Generate Password for the traefik Dashboard

```sh
    htpasswd -nb USER PASS | openssl base64 
    # edit the secrets to the new base64 code. 
```
#### Apply secret - The secret made for being use for the auth Middleware  
```sh
    vim traefik/dashboard/secret-dashboard.yaml
    kubectl apply -f dashboard/secret-dashboard.yaml
    kubectl get secrets --namespace traefik
```
#### Middleware - The authentication to your TRAEFIK dashboard. 
```sh
    kubectl apply -f dashboard/middleware.yaml
```
#### Ingress - An Ingress Route resource, for redirect to secure HTTPS and for routing within services.
```sh
    # edit the HOSTNAME for the service so ypu can reach it via web
    vim  traefik/dashboard/ingress.yaml
    kubectl apply -f dashboard/ingress.yaml
```




