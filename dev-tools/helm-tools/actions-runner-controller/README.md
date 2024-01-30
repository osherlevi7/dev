# GitHub Enterprise Server Authentication
The Actions Runner Controller must authenticate with GitHub Enterprise Server.
To authenticate the runner controller against GitHub Enterprise Server you have two options:

* PAT (Personal Access Token)
* GitHub Apps

**Note that the runners can be registered at different levels** 

* Enterprise
* Organization
* Repository

In the next steps, you will create a GitHub App to authenticate and use it at the organization level.

### Create a GitHub App
To create a GitHub App, you need to be an admin of the GitHub Enterprise Server instance. You can find more information about GitHub Apps here.
Navigate to your Organization settings.
For this post, you will create a GitHub App owned by an organization, in the upper-right corner of any page, click your profile photo, then click Your organizations.

Then, to the right of the organization, click Settings.
In the left sidebar, click  **Developer settings** .
Click New GitHub App.
In "GitHub App name", type the name of your app.
Optionally, in "Description", type a description of your app that users will see.
In "Homepage URL", type the URL where users can learn more about your app, you can point to the Actions Runner Controller GitHub repository.
In "Wehbook", uncheck Active.
Then configure the permissions for your app. For this post, you will need to select the following permissions: (we will use Organization Runners)

### Repository Permissions
* Actions (read)
* Metadata (read)
* Organization Permissions
* Self-hosted runners (read / write)

If you want to register the runners at the Repository level, you will need different permissions as documented here.
Keep the default values for the other options, and click Create GitHub App.
In the next screen, Generate a Private key, and download it. You will need it later. (file arc-private-private-key.pem in the following steps)

### Install the newly created GitHub App
In the application settings,
Find the Install App button. Click on it.
Select the organization where you want to install the app. Then click Install.
Select "All repositories" and click Install.

# Pre-req
**Setup gh-runner on k8s** 
* Install Docker.
* Install Helm 
* Install kubectl
### Cert-Manager
By default, actions-runner-controller uses cert-manager for certificate management of admission webhook, so we have to make sure cert-manager is installed on Kubernetes before we install actions-runner-controller. 
```sh
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.crds.yaml
  helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace
```
**https://cert-manager.io/docs/installation/helm/**

### PA token personal access token for REPO setting 
```sh
    export GITHUB_TOKEN="token"
    kubectl create ns actions-runner-system
    kubectl create secret generic controller-manager  -n actions-runner-system --from-literal=github_token=${GITHUB_TOKEN}
    helm install -n actions-runner-system actions-runner-controller actions-runner-controller/actions-runner-controller 
```


<br>
<br>



### PA token personal access token for ORG setting 
The GitHub App data (that you can get from the GitHub App settings page):
  * The App ID ( $GITHUB_APP_ID)
  * The App Private Key file ( $GITHUB_APP_PRIVATE_KEY_FILEPATH )
  * The APP Installation ID ( $GITHUB_APP_INSTALLATION_ID ). To get the Application Installation ID, go to the Application  Settings Page, and click on the Install App button. Then click on the Configure button. You will find the Installation ID in the URL of the page. (e.g. https://github.tugdualgrall.com/organizations/{ORG}/settings/installations/{INSTALL_ID} )

<br>

### Install the controller

```sh
    kubectl create namespace actions-runner-system
    helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
    helm repo update
    helm install -n actions-runner-system actions-runner-controller actions-runner-controller/actions-runner-controller
    kubectl set env deploy actions-runner-controller -c manager GITHUB_ENTERPRISE_URL="$GITHUB_SERVER_URL" --namespace actions-runner-system
```

### Create the secret of the GH Application 
```sh
$ kubectl create secret generic controller-manager \
    -n actions-runner-system \
    --from-literal=github_app_id=${GITHUB_APP_ID} \
    --from-literal=github_app_installation_id=${GITHUB_APP_INSTALLATION_ID} \
    --from-file=github_app_private_key=${GITHUB_APP_PRIVATE_KEY_FILEPATH}
```


### Create gh-runner repo deployment for REPO settings

**https://github.com/actions/actions-runner-controller/blob/master/docs/using-entrypoint-features.md**
```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
 name: dev-runner
 namespace: actions-runner-dev
spec:
 replicas: 2
 template:
   spec:
     repository: osherlevi7/dev
     labels:
      - k8s
      - gitops
```

### Create gh-runner repo deployment for ORG settings

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: runner-001
  namespace: runners
spec:
  replicas: 1
  template:
    spec:
      organization: demo
      labels:
        - arc
        - kubernetes
        - gke
      group: Default   
```



# apply the repo-runner 
```sh
  kubectl create -f runner.yaml
```
**https://github.com/actions/actions-runner-controller?tab=readme-ov-file**

## Docs

All additional docs are kept in the `docs/` folder, this README is solely for documenting the values.yaml keys and values

## Values

**_The values are documented as of HEAD, to review the configuration options for your chart version ensure you view this file at the relevant [tag](https://github.com/actions/actions-runner-controller/tags)_**

* _Default values are the defaults set in the charts `values.yaml`, some properties have default configurations in the code for when the property is omitted or invalid_

| Key                                                       | Description                                                                                                                               | Default                                                                                         |
|-----------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| `labels`                                                  | Set labels to apply to all resources in the chart                                                                                         |                                                                                                 |
| `replicaCount`                                            | Set the number of controller pods                                                                                                         | 1                                                                                               |
| `webhookPort`                                             | Set the containerPort for the webhook Pod                                                                                                 | 9443                                                                                            |
| `syncPeriod`                                              | Set the period in which the controller reconciles the desired runners count                                                               | 1m                                                                                              |
| `enableLeaderElection`                                    | Enable election configuration                                                                                                             | true                                                                                            |
| `leaderElectionId`                                        | Set the election ID for the controller group                                                                                              |                                                                                                 |
| `githubEnterpriseServerURL`                               | Set the URL for a self-hosted GitHub Enterprise Server                                                                                    |                                                                                                 |
| `githubURL`                                               | Override GitHub URL to be used for GitHub API calls                                                                                       |                                                                                                 |
| `githubUploadURL`                                         | Override GitHub Upload URL to be used for GitHub API calls                                                                                |                                                                                                 |
| `runnerGithubURL`                                         | Override GitHub URL to be used by runners during registration                                                                             |                                                                                                 |
| `logLevel`                                                | Set the log level of the controller container                                                                                             |                                                                                                 |
| `logFormat`                                               | Set the log format of the controller. Valid options are "text" and "json"                                                                 | text                                                                                            |
| `additionalVolumes`                                       | Set additional volumes to add to the manager container                                                                                    |                                                                                                 |
| `additionalVolumeMounts`                                  | Set additional volume mounts to add to the manager container                                                                              |                                                                                                 |
| `authSecret.create`                                       | Deploy the controller auth secret                                                                                                         | false                                                                                           |
| `authSecret.name`                                         | Set the name of the auth secret                                                                                                           | controller-manager                                                                              |
| `authSecret.annotations`                                  | Set annotations for the auth Secret                                                                                                       |                                                                                                 |
| `authSecret.github_app_id`                                | The ID of your GitHub App. **This can't be set at the same time as `authSecret.github_token`**                                            |                                                                                                 |
| `authSecret.github_app_installation_id`                   | The ID of your GitHub App installation. **This can't be set at the same time as `authSecret.github_token`**                               |                                                                                                 |
| `authSecret.github_app_private_key`                       | The multiline string of your GitHub App's private key. **This can't be set at the same time as `authSecret.github_token`**                |                                                                                                 |
| `authSecret.github_token`                                 | Your chosen GitHub PAT token. **This can't be set at the same time as the `authSecret.github_app_*`**                                     |                                                                                                 |
| `authSecret.github_basicauth_username`                    | Username for GitHub basic auth to use instead of PAT or GitHub APP in case it's running behind a proxy API                                |                                                                                                 |
| `authSecret.github_basicauth_password`                    | Password for GitHub basic auth to use instead of PAT or GitHub APP in case it's running behind a proxy API                                |                                                                                                 |
| `dockerRegistryMirror`                                    | The default Docker Registry Mirror used by runners.                                                                                       |                                                                                                 |
| `hostNetwork`                                             | The "hostNetwork" of the controller container                                                                                             | false                                                                                           |
| `dnsPolicy`                                               | The "dnsPolicy" of the controller container                                                                                               | ClusterFirst                                                                                    |
| `image.repository`                                        | The "repository/image" of the controller container                                                                                        | summerwind/actions-runner-controller                                                            |
| `image.tag`                                               | The tag of the controller container                                                                                                       |                                                                                                 |
| `image.actionsRunnerRepositoryAndTag`                     | The "repository/image" of the actions runner container                                                                                    | summerwind/actions-runner:latest                                                                |
| `image.actionsRunnerImagePullSecrets`                     | Optional image pull secrets to be included in the runner pod's ImagePullSecrets                                                           |                                                                                                 |
| `image.dindSidecarRepositoryAndTag`                       | The "repository/image" of the dind sidecar container                                                                                      | docker:dind                                                                                     |
| `image.pullPolicy`                                        | The pull policy of the controller image                                                                                                   | IfNotPresent                                                                                    |
| `metrics.serviceMonitor.enable`                           | Deploy serviceMonitor kind for for use with prometheus-operator CRDs                                                                      | false                                                                                           |
| `metrics.serviceMonitor.interval`                         | Configure the interval that Prometheus should scrap the controller's metrics                                                              | 1m                                                                                              |
| `metrics.serviceMonitor.namespace                         | Namespace which Prometheus is running in                                                                                                  | `Release.Namespace` (the default namespace of the helm chart).                                  |
| `metrics.serviceMonitor.timeout`                          | Configure the timeout the timeout of Prometheus scrapping.                                                                                | 30s                                                                                             |
| `metrics.serviceAnnotations`                              | Set annotations for the provisioned metrics service resource                                                                              |                                                                                                 |
| `metrics.port`                                            | Set port of metrics service                                                                                                               | 8443                                                                                            |
| `metrics.proxy.enabled`                                   | Deploy kube-rbac-proxy container in controller pod                                                                                        | true                                                                                            |
| `metrics.proxy.image.repository`                          | The "repository/image" of the kube-proxy container                                                                                        | quay.io/brancz/kube-rbac-proxy                                                                  |
| `metrics.proxy.image.tag`                                 | The tag of the kube-proxy image to use when pulling the container                                                                         | v0.13.1                                                                                         |
| `metrics.serviceMonitorLabels`                            | Set labels to apply to ServiceMonitor resources                                                                                           |                                                                                                 |
| `imagePullSecrets`                                        | Specifies the secret to be used when pulling the controller pod containers                                                                |                                                                                                 |
| `fullnameOverride`                                        | Override the full resource names	                                                                                                        |                                                                                                 |
| `nameOverride`                                            | Override the resource name prefix	                                                                                                        |                                                                                                 |
| `serviceAccount.annotations`                              | Set annotations to the service account                                                                                                    |                                                                                                 |
| `serviceAccount.create`                                   | Deploy the controller pod under a service account                                                                                         | true                                                                                            |
| `podAnnotations`                                          | Set annotations for the controller pod                                                                                                    |                                                                                                 |
| `podLabels`                                               | Set labels for the controller pod                                                                                                         |                                                                                                 |
| `serviceAccount.name`                                     | Set the name of the service account                                                                                                       |                                                                                                 |
| `securityContext`                                         | Set the security context for each container in the controller pod                                                                         |                                                                                                 |
| `podSecurityContext`                                      | Set the security context to controller pod                                                                                                |                                                                                                 |
| `service.annotations`                                     | Set annotations for the provisioned webhook service resource                                                                              |                                                                                                 |
| `service.port`                                            | Set controller service ports                                                                                                              |                                                                                                 |
| `service.type`                                            | Set controller service type                                                                                                               |                                                                                                 |
| `topologySpreadConstraints`                               | Set the controller pod topologySpreadConstraints                                                                                          |                                                                                                 |
| `nodeSelector`                                            | Set the controller pod nodeSelector                                                                                                       |                                                                                                 |
| `resources`                                               | Set the controller pod resources                                                                                                          |                                                                                                 |
| `affinity`                                                | Set the controller pod affinity rules                                                                                                     |                                                                                                 |
| `podDisruptionBudget.enabled`                             | Enables a PDB to ensure HA of controller pods                                                                                             | false                                                                                      |
| `podDisruptionBudget.minAvailable`                        | Minimum number of pods that must be available after eviction                                                                              |                                                                                                 |
| `podDisruptionBudget.maxUnavailable`                      | Maximum number of pods that can be unavailable after eviction. Kubernetes 1.7+ required.                                                  |                                                                                                 |
| `tolerations`                                             | Set the controller pod tolerations                                                                                                        |                                                                                                 |
| `env`                                                     | Set environment variables for the controller container                                                                                    |                                                                                                 |
| `priorityClassName`                                       | Set the controller pod priorityClassName                                                                                                  |                                                                                                 |
| `scope.watchNamespace`                                    | Tells the controller and the github webhook server which namespace to watch if `scope.singleNamespace` is true                            | `Release.Namespace` (the default namespace of the helm chart).                                  |
| `scope.singleNamespace`                                   | Limit the controller to watch a single namespace                                                                                          | false                                                                                           |
| `certManagerEnabled`                                      | Enable cert-manager. If disabled you must set admissionWebHooks.caBundle and create TLS secrets manually                                  | true                                                                                            |
| `runner.statusUpdateHook.enabled`                         | Use custom RBAC for runners (role, role binding and service account), this will enable reporting runner statuses                          | false                                                                                           |
| `admissionWebHooks.caBundle`                              | Base64-encoded PEM bundle containing the CA that signed the webhook's serving certificate                                                 |                                                                                                 |
| `githubWebhookServer.logLevel`                            | Set the log level of the githubWebhookServer container                                                                                    |                                                                                                 |
| `githubWebhookServer.logFormat`                           | Set the log format of the githubWebhookServer controller. Valid options are "text" and "json"                                             | text                                                                                            |
| `githubWebhookServer.replicaCount`                        | Set the number of webhook server pods                                                                                                     | 1                                                                                               |
| `githubWebhookServer.useRunnerGroupsVisibility`           | Enable supporting runner groups with custom visibility, you also need to set `githubWebhookServer.secret.enabled` to enable this feature. | false                                                                                           |
| `githubWebhookServer.enabled`                             | Deploy the webhook server pod                                                                                                             | false                                                                                           |
| `githubWebhookServer.queueLimit`                          | Set the queue size limit in the githubWebhookServer                                                                                       |                                                                                                 |
| `githubWebhookServer.secret.enabled`                      | Passes the webhook hook secret to the github-webhook-server                                                                               | false                                                                                           |
| `githubWebhookServer.secret.create`                       | Deploy the webhook hook secret                                                                                                            | false                                                                                           |
| `githubWebhookServer.secret.name`                         | Set the name of the webhook hook secret                                                                                                   | github-webhook-server                                                                           |
| `githubWebhookServer.secret.github_webhook_secret_token`  | Set the webhook secret token value                                                                                                        |                                                                                                 |
| `githubWebhookServer.imagePullSecrets`                    | Specifies the secret to be used when pulling the githubWebhookServer pod containers                                                       |                                                                                                 |
| `githubWebhookServer.nameOverride`                        | Override the resource name prefix	                                                                                                        |                                                                                                 |
| `githubWebhookServer.fullnameOverride`                    | Override the full resource names	                                                                                                        |                                                                                                 |
| `githubWebhookServer.serviceAccount.create`               | Deploy the githubWebhookServer under a service account                                                                                    | true                                                                                            |
| `githubWebhookServer.serviceAccount.annotations`          | Set annotations for the service account                                                                                                   |                                                                                                 |
| `githubWebhookServer.serviceAccount.name`                 | Set the service account name                                                                                                              |                                                                                                 |
| `githubWebhookServer.podAnnotations`                      | Set annotations for the githubWebhookServer pod                                                                                           |                                                                                                 |
| `githubWebhookServer.podLabels`                           | Set labels for the githubWebhookServer pod                                                                                                |                                                                                                 |
| `githubWebhookServer.podSecurityContext`                  | Set the security context to githubWebhookServer pod                                                                                       |                                                                                                 |
| `githubWebhookServer.securityContext`                     | Set the security context for each container in the githubWebhookServer pod                                                                |                                                                                                 |
| `githubWebhookServer.resources`                           | Set the githubWebhookServer pod resources                                                                                                 |                                                                                                 |
| `githubWebhookServer.topologySpreadConstraints`           | Set the githubWebhookServer pod topologySpreadConstraints                                                                                 |                                                                                                 |
| `githubWebhookServer.nodeSelector`                        | Set the githubWebhookServer pod nodeSelector                                                                                              |                                                                                                 |
| `githubWebhookServer.tolerations`                         | Set the githubWebhookServer pod tolerations                                                                                               |                                                                                                 |
| `githubWebhookServer.affinity`                            | Set the githubWebhookServer pod affinity rules                                                                                            |                                                                                                 |
| `githubWebhookServer.priorityClassName`                   | Set the githubWebhookServer pod priorityClassName                                                                                         |                                                                                                 |
| `githubWebhookServer.terminationGracePeriodSeconds`       | Set the githubWebhookServer pod terminationGracePeriodSeconds. Useful when using preStop hooks to drain/sleep.                            | `10`                                                                                            |
| `githubWebhookServer.lifecycle`                           | Set the githubWebhookServer pod lifecycle hooks                                                                                           | `{}`                                                                                            |
| `githubWebhookServer.service.type`                        | Set githubWebhookServer service type                                                                                                      |                                                                                                 |
| `githubWebhookServer.service.ports`                       | Set githubWebhookServer service ports                                                                                                     | `[{"port":80, "targetPort:"http", "protocol":"TCP", "name":"http"}]`                            |
| `githubWebhookServer.service.loadBalancerSourceRanges`    | Set githubWebhookServer loadBalancerSourceRanges for restricting loadBalancer type services                                               | `[]`                                                                                            |
| `githubWebhookServer.ingress.enabled`                     | Deploy an ingress kind for the githubWebhookServer                                                                                        | false                                                                                           |
| `githubWebhookServer.ingress.annotations`                 | Set annotations for the ingress kind                                                                                                      |                                                                                                 |
| `githubWebhookServer.ingress.hosts`                       | Set hosts configuration for ingress                                                                                                       | `[{"host": "chart-example.local", "paths": []}]`                                                |
| `githubWebhookServer.ingress.tls`                         | Set tls configuration for ingress                                                                                                         |                                                                                                 |
| `githubWebhookServer.ingress.ingressClassName`            | Set ingress class name                                                                                                                    |                                                                                                 |
| `githubWebhookServer.podDisruptionBudget.enabled`         | Enables a PDB to ensure HA of githubwebhook pods                                                                                          | false                                                                                           |
| `githubWebhookServer.podDisruptionBudget.minAvailable`    | Minimum number of pods that must be available after eviction                                                                              |                                                                                                 |
| `githubWebhookServer.podDisruptionBudget.maxUnavailable`  | Maximum number of pods that can be unavailable after eviction. Kubernetes 1.7+ required.                                                  |                                                                                                 |
| `actionsMetricsServer.logLevel`                           | Set the log level of the actionsMetricsServer container                                                                                   |                                                                                                 |
| `actionsMetricsServer.logFormat`                          | Set the log format of the actionsMetricsServer controller. Valid options are "text" and "json"                                            | text                                                                                            |
| `actionsMetricsServer.enabled`                            | Deploy the actions metrics server pod                                                                                                     | false                                                                                           |
| `actionsMetricsServer.secret.enabled`                     | Passes the webhook hook secret to the actions-metrics-server                                                                              | false                                                                                           |
| `actionsMetricsServer.secret.create`                      | Deploy the webhook hook secret                                                                                                            | false                                                                                           |
| `actionsMetricsServer.secret.name`                        | Set the name of the webhook hook secret                                                                                                   | actions-metrics-server                                                                          |
| `actionsMetricsServer.secret.github_webhook_secret_token` | Set the webhook secret token value                                                                                                        |                                                                                                 |
| `actionsMetricsServer.imagePullSecrets`                   | Specifies the secret to be used when pulling the actionsMetricsServer pod containers                                                      |                                                                                                 |
| `actionsMetricsServer.nameOverride`                       | Override the resource name prefix	                                                                                                        |                                                                                                 |
| `actionsMetricsServer.fullnameOverride`                   | Override the full resource names	                                                                                                        |                                                                                                 |
| `actionsMetricsServer.serviceAccount.create`              | Deploy the actionsMetricsServer under a service account                                                                                   | true                                                                                            |
| `actionsMetricsServer.serviceAccount.annotations`         | Set annotations for the service account                                                                                                   |                                                                                                 |
| `actionsMetricsServer.serviceAccount.name`                | Set the service account name                                                                                                              |                                                                                                 |
| `actionsMetricsServer.podAnnotations`                     | Set annotations for the actionsMetricsServer pod                                                                                          |                                                                                                 |
| `actionsMetricsServer.podLabels`                          | Set labels for the actionsMetricsServer pod                                                                                               |                                                                                                 |
| `actionsMetricsServer.podSecurityContext`                 | Set the security context to actionsMetricsServer pod                                                                                      |                                                                                                 |
| `actionsMetricsServer.securityContext`                    | Set the security context for each container in the actionsMetricsServer pod                                                               |                                                                                                 |
| `actionsMetricsServer.resources`                          | Set the actionsMetricsServer pod resources                                                                                                |                                                                                                 |
| `actionsMetricsServer.topologySpreadConstraints`          | Set the actionsMetricsServer pod topologySpreadConstraints                                                                                |                                                                                                 |
| `actionsMetricsServer.nodeSelector`                       | Set the actionsMetricsServer pod nodeSelector                                                                                             |                                                                                                 |
| `actionsMetricsServer.tolerations`                        | Set the actionsMetricsServer pod tolerations                                                                                              |                                                                                                 |
| `actionsMetricsServer.affinity`                           | Set the actionsMetricsServer pod affinity rules                                                                                           |                                                                                                 |
| `actionsMetricsServer.priorityClassName`                  | Set the actionsMetricsServer pod priorityClassName                                                                                        |                                                                                                 |
| `actionsMetricsServer.terminationGracePeriodSeconds`      | Set the actionsMetricsServer pod terminationGracePeriodSeconds. Useful when using preStop hooks to drain/sleep.                           | `10`                                                                                            |
| `actionsMetricsServer.lifecycle`                          | Set the actionsMetricsServer pod lifecycle hooks                                                                                          | `{}`                                                                                            |
| `actionsMetricsServer.service.type`                       | Set actionsMetricsServer service type                                                                                                     |                                                                                                 |
| `actionsMetricsServer.service.ports`                      | Set actionsMetricsServer service ports                                                                                                    | `[{"port":80, "targetPort:"http", "protocol":"TCP", "name":"http"}]`                            |
| `actionsMetricsServer.service.loadBalancerSourceRanges`   | Set actionsMetricsServer loadBalancerSourceRanges for restricting loadBalancer type services                                              | `[]`                                                                                            |
| `actionsMetricsServer.ingress.enabled`                    | Deploy an ingress kind for the actionsMetricsServer                                                                                       | false                                                                                           |
| `actionsMetricsServer.ingress.annotations`                | Set annotations for the ingress kind                                                                                                      |                                                                                                 |
| `actionsMetricsServer.ingress.hosts`                      | Set hosts configuration for ingress                                                                                                       | `[{"host": "chart-example.local", "paths": []}]`                                                |
| `actionsMetricsServer.ingress.tls`                        | Set tls configuration for ingress                                                                                                         |                                                                                                 |
| `actionsMetricsServer.ingress.ingressClassName`           | Set ingress class name                                                                                                                    |                                                                                                 |
| `actionsMetrics.serviceMonitor.enable`                    | Deploy serviceMonitor kind for for use with prometheus-operator CRDs                                                                      | false                                                                                           |
| `actionsMetrics.serviceMonitor.interval`                  | Configure the interval that Prometheus should scrap the controller's metrics                                                              | 1m                                                                                              |
| `actionsMetrics.serviceMonitor.namespace`                 | Namespace which Prometheus is running in.                                                                                                 | `Release.Namespace` (the default namespace of the helm chart).                                  |
| `actionsMetrics.serviceMonitor.timeout`                   | Configure the timeout the timeout of Prometheus scrapping.                                                                                | 30s                                                                                             |
| `actionsMetrics.serviceAnnotations`                       | Set annotations for the provisioned actions metrics service resource                                                                      |                                                                                                 |
| `actionsMetrics.port`                                     | Set port of actions metrics service                                                                                                       | 8443                                                                                            |
| `actionsMetrics.proxy.enabled`                            | Deploy kube-rbac-proxy container in controller pod                                                                                        | true                                                                                            |
| `actionsMetrics.proxy.image.repository`                   | The "repository/image" of the kube-proxy container                                                                                        | quay.io/brancz/kube-rbac-proxy                                                                  |
| `actionsMetrics.proxy.image.tag`                          | The tag of the kube-proxy image to use when pulling the container                                                                         | v0.13.1                                                                                         |
| `actionsMetrics.serviceMonitorLabels`                     | Set labels to apply to ServiceMonitor resources                                                                                           |                                                                                                 |
