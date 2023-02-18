#!/bin/bash
echo "Create GCP group instance"
## functions
function usage() {
  echo "$0 <project id> <name> <environment_type> <gcp zone> <service_account>"
  echo "exampls: $0  test performance us-central1"
  exit 1
}
## main
if [ $# -ne 5 ]; then 
   usage
else
   project=$1
   name=$2
   environment=$3
   zone=${4:-'us-central1-a'}
   service_account=${5:-gcr-sa@.iam.gserviceaccount.com}
fi	
echo "#create instance-template"
echo "#------------------------"
gcloud compute instances create --project=$project ${name}-${environment} \
        --no-boot-disk-auto-delete --no-address \
        --boot-disk-size=100 \
        --image-family=ubuntu-pro-2004-lts --image-project=ubuntu-os-pro-cloud \
        --machine-type=e2-standard-4 \
        --labels=environment=${environment} --zone=$zone \
        --service-account=$service_account \
	--scopes="cloud-platform" \
        --tags=allow-health-check \
        --metadata startup-script=''