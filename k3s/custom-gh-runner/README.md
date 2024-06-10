## Running the Runner in Docker 

Kubernetes inside a container. </br>

### Security notes

* Running in Docker needs high priviledges.
* Would not recommend to use these on public repositories.
* Would recommend to always run your CI systems in seperate Kubernetes clusters.

### Creating a Dockerfile
The runner contain the following params

* RUNNER_VERSION
* GITHUB_ORG
* RUNNER_TOKEN

> The container should have the docker engine installed. 
> The Node-JS 20 has been installed for npm builds of the runner itself. 
> Ansible core has been added for running ansible-playbooks 
> Ran the running command via entrypoint. 


<hr> 

# BUILD
cd to the self-hosted-runner dir
```sh
cd custom-gh-runner
docker build . -t  -e <org-name>/gh-runner-k8s:latest    
docker push <org-name>/gh-runner-k8s:latest   
# running locally
docker run  -it -e GITHUB_PERSONAL_TOKEN=ghp_XXXXXX <org-name>/gh-runner-k8s:latest
```
# ORG CUSTOM GH-RUNNER [Custom image runner from ECR]
#### Create the namespace 
```sh
    kubectl create ns gh-runner
```
#### login to the ECR 
```sh
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 104939124827.dkr.ecr.us-east-1.amazonaws.com
```
#### add the github-token secrets and the ECR auth secrets
```sh
kubectl -n gh-runner create secret generic github-secret --from-literal GITHUB_PERSONAL_TOKEN="ghp_XXXXXX"
kubectl create --namespace gh-runner secret generic ecr-creds --from-file=.dockerconfigjson=path/to/docker/config.json --type=kubernetes.io/dockerconfigjson
```
#### Configure rhe Runner details
```sh
vim entrypoint.sh
#     #!/bin/sh

# # Define registration URL
# registration_url="https://api.github.com/orgs/<org-name>/actions/runners/registration-token"

# # Logging functions for better readability
# log_info() {
#     echo "INFO: $1"
# }

# log_error() {
#     echo "ERROR: $1" >&2
# }

# # Exit the script with an error message
# exit_with_error() {
#     log_error "$1"
#     exit 1
# }

# # Fetch registration token from GitHub API
# log_info "Requesting registration URL at '${registration_url}'"
# payload=$(curl -sX POST -H "Authorization: token ${GITHUB_PERSONAL_TOKEN}" "${registration_url}")

# if [ -z "$payload" ]; then
#     exit_with_error "Failed to get payload from GitHub API."
# fi

# RUNNER_TOKEN=$(echo "$payload" | jq .token --raw-output)

# if [ -z "$RUNNER_TOKEN" ]; then
#     exit_with_error "Failed to extract runner token from the payload."
# fi

# log_info "Runner token received successfully."

# # Configure the GitHub Actions Runner
# ./config.sh \
#     --name "gh-runner" \
#     --token "${RUNNER_TOKEN}" \
#     --labels "k8s" \
#     --url "https://github.com/${GITHUB_ORG}" \
#     --work "/work" \
#     --unattended \
#     --replace

# # Function to remove the runner
# remove_runner() {
#     log_info "Removing runner..."
#     ./config.sh remove --unattended --token "${RUNNER_TOKEN}"
# }

# # Trap signals and remove runner on exit
# trap 'remove_runner; exit 130' INT
# trap 'remove_runner; exit 143' TERM

# # Start the runner process
# log_info "Starting runner..."
# ./run.sh "$*" &

# # Wait for the runner process
# wait $!
```

#### Install the runner locally
```sh
kubectl -n gh-runner apply -f kubernetes.yaml
```
