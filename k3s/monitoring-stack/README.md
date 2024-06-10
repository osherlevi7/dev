# Monitoring Stack on K3s

This repository contains a monitoring stack for K3s, a lightweight Kubernetes distribution. The monitoring stack includes various tools and components to help you monitor the health and performance of your K3s cluster.

## Prerequisites

Before getting started, make sure you have the following prerequisites installed:
- K3s: [Installation Guide](https://k3s.io/)
- Helm: [Installation Guide](https://helm.sh/docs/intro/install/)

## Installation
To install the monitoring stack on your K3s cluster, follow these steps:

1. Add the Helm Cahrt:

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

2. Create the Namespace:

```shell
kubectl create ns monitoring
```

3. Create the prometheus dashboard user and password secret:

```shell
echo -n 'adminuser' > ./admin-user 
echo -n 'p@ssword!' > ./admin-password
kubectl create secret generic grafana-admin-credentials --from-file=./admin-user --from-file=admin-password -n monitoring
rm admin-user && rm admin-password
```

4. Install the monitoring-stack:

```shell
# edit the values file [https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml]
vim values.yaml 
helm install -n monitoring prometheus prometheus-community/kube-prometheus-stack -f values.yaml

# View the stack 
kubectl --namespace monitoring get pods -l "release=prometheus"
```


# Expose the Grafana to the world 

```sh
aws iam create-role --role-name CertManagerRoute53Role --assume-role-policy-document file://trust-policy.json
```
```sh
aws iam put-role-policy --role-name CertManagerRoute53Role --policy-name CertManagerRoute53Policy --policy-document file://route53-policy.json
```
