
# Add Portainer on NodePort 30777
```sh
    kubectl create namespace portainer
    kubectl apply -n portainer -f https://raw.githubusercontent.com/portainer/k8s/master/deploy/manifests/portainer/portainer.yaml
```