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

  if [[ $CLUSTER_NAME=='production' || $CLUSTER_NAME=='prod' ]];
  then
    OLD_CIDR=$(gcloud container clusters describe $CLUSTER_NAME --format json --zone $CLUSTER_ZONE --project $PROJECT | jq -r '.masterAuthorizedNetworksConfig.cidrBlocks[] | .cidrBlock' | tr '\n' ',')
    echo "The existing master authorized networks were $OLD_CIDR"
    echo "gcloud container clusters update"
    gcloud container clusters update $CLUSTER_NAME --master-authorized-networks "$OLD_CIDR$NEW_CIDR" --enable-master-authorized-networks --zone $CLUSTER_ZONE --project $PROJECT
    else
    OLD_CIDR=$(gcloud container clusters describe $CLUSTER_NAME --format json --zone $CLUSTER_ZONE-c --project $PROJECT | jq -r '.masterAuthorizedNetworksConfig.cidrBlocks[] | .cidrBlock' | tr '\n' ',')
    echo "The existing master authorized networks were $OLD_CIDR"
    echo "gcloud container clusters update"
  # Update
    gcloud container clusters update $CLUSTER_NAME --master-authorized-networks "$OLD_CIDR$NEW_CIDR" --enable-master-authorized-networks --zone $CLUSTER_ZONE-c --project $PROJECT
    fi
fi

