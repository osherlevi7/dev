#!/bin/bash
#set -e



function usage() {
  echo "$0 <cluster_name> <cluster_zone> <project>"
  exit 1
}


if [ $# -ne 3 ]; then
   usage
else
   
  NEW_CIDR=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2"/32"}')
  CLUSTER_NAME=$1
  CLUSTER_ZONE=$2
  PROJECT=$3
  OLD_CIDR=$(gcloud container clusters describe $CLUSTER_NAME --format json --zone $CLUSTER_ZONE --project $PROJECT | jq -r '.masterAuthorizedNetworksConfig.cidrBlocks[] | .cidrBlock' | tr '\n' ',')
  echo "The existing master authorized networks were $OLD_CIDR"

  # Update
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  sudo apt update
  sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin kubectl
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
  gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $PROJECT
  gcloud container clusters update $CLUSTER_NAME --master-authorized-networks "$OLD_CIDR$NEW_CIDR" --enable-master-authorized-networks --zone $CLUSTER_ZONE --project $PROJECT

fi
