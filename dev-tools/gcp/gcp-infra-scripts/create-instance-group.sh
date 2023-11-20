#!/bin/bash
set -x 
echo "Create GCP group instance"
## functions
function usage() {
  echo "$0 <project id> <group_name> <template name> <environment_type>"
  exit 1
}
## main
if [ $# -ne 4 ]; then 
   usage
else
   project=$1
   name=$2
   template_name=$3
   environment=$4
   region="us-central1"
fi	
gcloud compute instance-groups managed create --project=$project instance-group--$name \
               --size=2 --template=template--$template_name \
               --base-instance-name="-$environment" \
               --initial-delay=60 \
               --region=$region

gcloud compute instance-groups set-named-ports --project=$project instance-group--$name \
       	--named-ports="http:80" \
	--region=$region
