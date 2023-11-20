#! /bin/bash

branch=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/branch" -H "Metadata-Flavor: Google")
apt update && apt-get install ca-certificates curl gnupg lsb-release make -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update && apt install docker-ce docker-ce-cli containerd.io -y
apt install docker-compose-plugin -y
apt install make -y
usermod -aG docker ubuntu
echo "Cloning  compose repo for devops branch"
token=$(gcloud secrets versions access latest --secret=github-api-tokens)
su - ubuntu -c "git clone --branch ${branch} https://${token}@github.com/compose.git"
su - ubuntu -c "cd compose && gcloud auth configure-docker -q && make pull && make up"
