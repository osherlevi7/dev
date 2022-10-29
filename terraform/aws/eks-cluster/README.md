# EKS cluster using eksctl command 

# Install eksctl

```shell
    $ curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

    $ sudo mv /tmp/eksctl /usr/local/bin

    $ eksctl version
```
   
   
**We will preform an cluster named "test-cluster" with 2 nodes with the name group of "linux-nodes" 
The instances will be created inside the cluster with the machine type of t2.micro** 

## Create the cluster
```shell
$ eksctl create cluster \
    > --name test-cluster \
    > --version 1.22 \ 
    > --region us-east-1 \ 
    > --nodegroup-name linux-nodes \
    > --node-type t2.micro \
    > --nodes 2
```

## Delete the cluster

```shell
    $ eksctl delete cluster --name test-cluster
```