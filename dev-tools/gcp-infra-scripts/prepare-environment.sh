#!/bin/bash

set -x

echo "Create GCP instance"

## functions

function usage() {
  echo "$0 <project id> <name> <zone>"
  exit 1
}

## main

if [ $# -ne 3 ]; then
   usage
else
   project=$1
   name=$2
   zone=$3
fi


gcloud compute instances create --project=$project dev-${name%%.*} \
        --no-boot-disk-auto-delete --no-address \
        --boot-disk-size=200 \
        --image-family=ubuntu-pro-2004-lts --image-project=ubuntu-os-pro-cloud \
        --machine-type=e2-standard-4 \
        --labels=owner=${name//['.''@']/-} --zone=$zone \
        --service-account='gcr-sa@.iam.gserviceaccount.com' \
	--scopes="cloud-platform" \
        --tags=allow-health-check \
        --metadata startup-script=''

