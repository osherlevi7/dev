#!/bin/bash

set -xe

echo "Create GCP group instance"

## functions

function usage() {
  echo "$0 <project id> <service_account_name> "
  exit 1
}

## main

if [ $# -ne 2 ]; then 
   usage
else
   project=$1
   service_account_name=$2
fi	

# get full email id of new service account
service_account_id=$(gcloud iam service-accounts list --filter="email ~ ^${service_account_name}" --format='value(email)')

# create service account in project
gcloud iam service-accounts delete $service_account_id --project=$project --quiet

