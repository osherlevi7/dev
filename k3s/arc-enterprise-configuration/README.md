

## ACR scale set - Scale Set Docker-in-Docker 

**Change directory runner-scale-set-dind**
```sh
cd arc-enterprise-configuration/runner-scale-set-dind/
kubectl create ns arc-dind
```
**Create also the secret from the gh-app configuration**
```sh
kubectl create secret generic gh-app-secret -n arc-dind  --from-literal=github_app_id=720406 --from-literal=github_app_installation_id=45710105 --from-literal=github_app_private_key="$(cat /Users/osherlevi/Desktop/k8s-app-gh-runner.pem)" 
```

#### Edit the <Values.yaml> file
**the value file we specifies the APP ID and the APP key secrets**

```yaml
- github_token
+ githubConfigSecret: <secret name>
<!-- - proxy if need to secure the controller to our cluster -->
- runnerGroup: <runner-group-name-dind>
- runnerScaleSetName: <No labels anymore - scaleSet_Name>
- containerMode:    
    type: "dind"
    spec:
    containers:
      - name: runner-dind
        image: ghcr.io/actions/actions-runner:latest
        command: ["/home/runner/run.sh"]
```
#### Install the docker in docker runner scale set
```sh
helm install k8s-gh-runners-dind --namespace arc-dind -f values.yaml oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set 
```
<br>
<br>

## ACR scale set - Scale Set K8s
**Change dir runner-scale-set-kubernetes**
```sh 
cd arc-enterprise-configuration/runner-scale-set-kubernetes/
kubectl create ns arc-runners
```
**Create secret from the gh-app configuration**
```sh
kubectl create secret generic gh-app-secret -n arc-runners  --from-literal=github_app_id=720406 --from-literal=github_app_installation_id=45710105 --from-literal=github_app_private_key="$(cat /Users/osherlevi/Desktop/k8s-app-gh-runner.pem)" 
```


#### Edit the <Values.yaml> file
**On the value file we specifies the APP ID and the APP key secrets**
```yaml
- github_token
+ githubConfigSecret: <secret name>
<!-- - proxy if need to secure the controller to our cluster -->
+ runnerGroup: <runner-group-name-k8s>
+ runnerScaleSetName: <No labels anymore - scaleSet_Name>
+ containerMode:    
    type: "kubernetes"
+ kubernetesModeWorkVolumeClaim:
    accessModes: ["ReadWriteOnce"]
+ storageClassName: "openebs-hostpath"
    resources:
    requests:
        storage: 1Gi
+ spec:
    containers:
      - name: runner
        imagePullPolicy: Always
        image: osherlevi7/gh-runner-k8s:latest
        env:
        - name: GITHUB_PERSONAL_TOKEN 
          valueFrom:
            secretKeyRef:
              name: github-secret
              key: GITHUB_PERSONAL_TOKEN
        - name: ACTIONS_RUNNER_REQUIRE_JOB_CONTAINER
          value: "false"
    imagePullSecrets:
      - name: ecr-secret
```

### PVC VOLUMES
#### For running ARC kubernetes we must take care of the storage volume claim 
#### openEBS is an open source volume claim on helm chart which is easy to install.  [https://openebs.io/]

```sh
helm repo add openebs https://openebs.github.io/charts
helm repo update 
helm install openebs openebs/openebs --namespace openebs --create-namespace
```

Install the docker in docker runner scale set 
```sh
helm install k8s-gh-runners --namespace arc-runners -f values.yaml oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set 
```
