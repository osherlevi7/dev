# Jenkins master on GKE cluster using Helm-Chart


# GKE

### _First create the cluster on GKE_

``` sh
$ gcloud container clusters create jenkins-cluster \
    --name-space jenkins-ns \
    --num-nodes 2 \
    —-zone us-central1-a \
    —-machine-type n1-standard-2 \
    —-scopes “https://www.googleapis.com/auth/source.read_write,cloud-platform"
```

### _List the clusters_
``` sh
$ gcloud container clusters list --project=jenkins
```

### _Fetching the cluster credentials_
```sh
$ gcloud beta container clusters get-credentials jenkins-cd --region us-east1-d --project jenkins
``` 

# HELM

### _To install Helm(v3) in your cluster_
```sh

$ curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
$ sudo apt-get install apt-transport-https --yes
$ echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
$ sudo apt-get update
$ sudo apt-get install helm
```
### _List your helm repos_
```sh
$ helm repo list
```

### _To give yourself cluster administrator permission_
``` sh 
$ kubectl create clusterrolebinding cluster-admin-role --clusterrole=cluster-admin --user=$(gcloud config get-value account)
```
### _list your helm releases_
``` sh 
$ helm list -n jenkins-ns
```

# JENKINS

### _install Jenkins on Kubernetes cluster via Helm_
```sh
$ helm repo add jenkinsci https://charts.jenkins.io
$ helm repo update
$ helm install jenkins-tool jenkinsci/jenkins
```

### _List your pods after helm chart creation_
```sh
$ kubectl get pods -n jenkins-ns
```

### _Configure the Jenkins service account to be able to deploy to the cluster_
```sh
$ kubectl create clusterrolebinding jenkins-deploy --clusterrole=cluster-admin --serviceaccount=<serviceAccount>
```

### _Jenkins user and password_
```sh
$ printf $(kubectl get secret --namespace default jenkins-tool -o jsonpath=”{.data.jenkins-admin-password}” | base64 — decode);echo
```

### _List your services_
```sh
$ kubectl get svc -n jenkins-ns
```


