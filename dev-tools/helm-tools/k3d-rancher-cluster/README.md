# k3d-rancher-cluster
```sh
# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# install helm (this one takes some time)
curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
# Creating the cluster 
k3d cluster create mycluster -p "8900:30080@agent:0" -p "8901:30081@agent:0" -p "8902:30082@agent:0" --agents 2

```
> This will create a cluster named “mycluster” with 3 ports exposed 30080, 30081 and 30082. These ports will map to ports 8900, 8901 and 8902 of your localhost respectively. The cluster will have 1 master node and 2 worker nodes. You can adjust these settings using the p and the agent flags as you wish.


```sh
# Add the rancher repo 
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
# Install it 
helm install rancher rancher-latest/rancher \
   --namespace rancher \
   --create-namespace \
   --set ingress.enabled=false \
   --set tls=external \
   --set replicas=1
```