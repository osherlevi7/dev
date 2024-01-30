# K3s Local HA Cluster

<br>
<br>

# CERTS MANAGER
**Install - Cert manager for management certs within the cluster.**
```sh
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.7.0
```

<br>
<br>

# RANCHER
**Instal - Rancher is the cluster management dashboard solution**  
The Rancher is made for installing more k8s resources in UI way and allow you to see everything in front of you. 
```sh
kubectl create namespace cattle-system
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update
helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher.home --set global.cattle.psp.enabled=false
# Check the rollout update  
kubectl -n cattle-system rollout status deploy/rancher
# Expose the rancher service
kubectl expose deployment rancher -n cattle-system  --type=LoadBalancer --name=rancher-lb --port=443
```
#### bootstrap pass 
```sh
kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'
```
#### If this is the first time you installed Rancher, get started by running this command and clicking the URL it generates:
```sh
echo https://rancher.home/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')
```

<br>
<br>

# LONG_HORN 
**LongHorn is a project for sharing the storage system within the cluster and between the nodes.**
**The project will share the storage of each node to a entire share nfs system**
**Dependencies - Install it on the node machines.**
```sh
sudo apt update && sudo apt install open-iscsi curl grep nfs-common
```
#### install the chart via rancher 
```sh
# open the rancher dashboard
https://192.168.0.222
# navigate to the Chart tab 
# search for "Longhorn" chart
# install the Longhorn project
```

<br>
<br>


## ACR scale set   - Controller for K8S type and for DinD type.  
#### Change dir to the controller. 
```sh
cd arc-enterprise-configuration/controller
```
#### Run the controller with the value file in it
```sh
helm install erc --namespace arc-systems --create-namespace -f values.yaml oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller 
```


<br>
<br>



# GENERAL 
#### Login to the ECR
```sh
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 104939124827.dkr.ecr.us-east-1.amazonaws.com
```
#### Secrets for ECR
```sh
# kubectl create --namespace arc-runners secret generic ecr-creds --from-file=.dockerconfigjson=/home/scadmin/.docker/config.json --type=kubernetes.io/dockerconfigjso
```
#### Secrets for the gh-token for token provisionning for my custom runner image 
```sh
kubectl -n arc-runners create secret generic github-secret --from-literal GITHUB_PERSONAL_TOKEN="ghp_XXXXXX"
```

```sh
kubectl create -n arc-runners secret docker-registry ecr-secret --docker-server=104939124827.dkr.ecr.us-east-1.amazonaws.com --docker-username=AWS --docker-password=$(aws ecr get-login-password --region us-east-1)
```