# Cert Manager With Let's encrypt and AWS Route53

**Install - Cert manager for management certs within the cluster**
```sh
    kubectl create namespace cert-manager
    kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.14.4/cert-manager.crds.yaml
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.14.4 -f values.yaml --set installCRD=true
```

# Token for route53 
#### This token is a service account that have permissions to create an DNS challenges to AWS rout53
```sh
    kubectl create -n cert-manager secret generic route53-secret-new --from-env-file=.env
    kubectl apply -f issuers/letsencrypt-stg.yaml # this point to stg env on letsencrypt for propagate certificates. 
    kubectl apply -f k3s-com.yaml # this create an wiled card cert for the subdomain *.k3s.com
    kubectl get challenges # status for the DNS challenge, if not found, we got certificate.
```
