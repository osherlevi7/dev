#!/bin/bash

## functions
function usage() {
  echo "$0 <project id> <name> <region> <environment> <topic>"
  exit 1
}
## main
if [ $# -ne 5 ]; then
   usage
else
   project=$1
   name=$2
   region=${3:-us-east1}
   environment=$4
   [ "${environment}" == "production" ] && machine_type=n1-standard-2
   [ "${environment}" != "production" ] && machine_type=n1-standard-1
   topic=$5
fi
# create service account in project
echo "Create dataflow for $environment"
#topic_list="a b c d"
gcloud dataflow jobs run --region $region ps_to_bq-${name}-${environment} \
                         --gcs-location gs://dataflow-templates-us-east1/latest/PubSub_to_BigQuery \
                         --staging-location gs://dataflows_develop_temporary/followup \
                         --max-workers 2 --num-workers 1 --worker-region $region \
                         --worker-machine-type $machine_type \
                         --disable-public-ips \
                         --parameters inputTopic="projects/${project}/topics/${topic}",outputTableSpec="${project:a" \
			 --additional-experiments disable_runner_v2_reason=template \
			 --enable-streaming-engine \
			 --service-account-email="sa@.iam.gserviceaccount.com"
#         --network=network --subnetwork=regions/$region/subnetworks/default \
