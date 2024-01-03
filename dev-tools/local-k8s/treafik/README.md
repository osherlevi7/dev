# Add Treafik for your local cluster 


```sh
    helm repo add traefik https://helm.traefik.io/traefik
    helm repo update 
    kubectl create namespace traefik
```

```sh
    helm install --namespace=traefik traefik traefik/traefik --values=values.yaml
```


## Middleware 

```sh
    kubectl apply -f default-headers.yaml
    kubectl get middleware
```


## Treafik Dashboard 

Generate Password
```sh
    htpasswd -nb osher password | openssl base64 
```
Apply secret
```sh
    kubectl apply -f secret-dashboard.yaml
    kubectl get secrets --namespace traefik
```