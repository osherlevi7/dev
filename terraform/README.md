# terraform

**init**
* add those two env variables to your shell profile (~/.zprofile or ~/.profile)
```bash
export KUBE_CONFIG_PATH=~/.kube/config
export USE_GKE_GCLOUD_AUTH_PLUGIN=False
source ~/.zprofile | source ~/.profile
```

* connect to the cluster 
```bash
gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}
```

* Installations needed
**CLI**
```bash
brew install traefik cilium-cli hubble kubectl terraform helm
```
**CASKS**
```bash
brew install --cask google-cloud-sdk
```

## On first setup
>TODO: write CD script

1. create environment folder with module (see example)
2. when on the created folder
```bash
terraform init  # download modules & pull/create remote backend
terraform apply # create cluster/machine
```
* on cleanup
```bash
terraform destroy
```

**secrets**
```bash
gcloud iam service-accounts keys create ./credentials.json \
  --iam-account service-account@developer.gserviceaccount.com
```
```bash
kubectl create secret generic "external-dns-sa" --namespace "default" \
  --from-file ./credentials.json
```
**move the secret to the desired namespace**
```bash
kubectl get secret "external-dns-sa" --namespace=default -o yaml | \
  sed 's/namespace: .*/namespace: external-dns/' | \
    kubectl apply -f -

kubectl get secret "external-dns-sa" --namespace=default -o yaml | \
  sed 's/namespace: .*/namespace: cert-manager/' | \
    kubectl apply -f -
```
