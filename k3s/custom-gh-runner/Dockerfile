FROM python:3.11.5-slim-bullseye

ENV RUNNER_VERSION=2.312.0
ENV GITHUB_ORG ""
ENV RUNNER_TOKEN ""
# ENV GITHUB_REPOSITORY ""

# Install Docker -> https://docs.docker.com/engine/install/debian/

# Add Docker's official GPG key:
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg

# Add Node20 
ENV NODE_MAJOR=20
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee 
RUN apt-get update && apt-get install nodejs -y
# Add the repository to Apt sources:
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update

# I only install the CLI, we will run docker in another container!
RUN apt-get update && apt-get install -y sudo jq tar docker-ce-cli openssh-client sshpass
RUN python3 -m pip install requests argparse PyYAML==6.0.1 ansible ansible-core 

RUN useradd -m github && \
  usermod -aG sudo github && \
  echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER github
WORKDIR /actions-runner
RUN curl -Ls https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz | sudo tar xz \
  && sudo ./bin/installdependencies.sh

COPY  entrypoint.sh  /actions-runner/entrypoint.sh
RUN sudo chown github:github /actions-runner
RUN sudo chown github:github /actions-runner/bin
RUN sudo chmod u+x entrypoint.sh
# Copy the index.js file to the required directory
COPY index.js /home/runner/k8s/index.js
RUN sudo chmod u+x /home/runner/k8s/index.js
RUN sudo chown github:github /home/runner/k8s/index.js

# #working folder for the runner 
RUN sudo mkdir /work 
RUN sudo chown github:github /work
# Setup for ssh onto github
RUN ssh-keygen -t rsa -q -f "$HOME/.ssh/id_rsa" -N ""


ENTRYPOINT ["/actions-runner/entrypoint.sh"]