#!/bin/bash
echo "Create GCP VM-template"
## functions
function usage() {
  echo "$0 <project id> <template name> <environment_type>"
  exit 1
}
## main
if [ $# -ne 3 ]; then 
   usage
else
   project=$1
   name=$2
   environment=$3
   region="us-central-1"
fi	
gcloud compute instance-templates create --project=$project template--$name \
        --no-boot-disk-auto-delete --no-address \
        --boot-disk-size=200 \
        --image-family=ubuntu-pro-2004-lts --image-project=ubuntu-os-pro-cloud \
        --machine-type=e2-standard-4 \
        --labels=environment=$3 --region=$region \
	     --service-account='gcr-sa@.iam.gserviceaccount.com'  \
	     --tags=allow-health-check \
        --metadata startup-script=''