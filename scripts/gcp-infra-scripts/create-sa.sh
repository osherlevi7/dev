#!/bin/bash
set -e
echo "Create GCP service account"
## functions
function usage() {
  echo "$0 <project id> <service_account_name> <roles seperate by ':' e.g roles/logging.logWriter:roles/monitoring.metricWriter>"
  exit 1
}
## main
if [ $# -ne 3 ]; then 
   usage
else
   project=$1
   service_account_name=$2
   roles=$3
fi	
# create service account in project
gcloud iam service-accounts create $service_account_name --display-name "$name service account" --project=$project
# get full email id of new service account
service_account_id=$(gcloud iam service-accounts --project=$project list --filter="email ~ ^${service_account_name}" --format='value(email)')
# download key for service account
gcloud iam service-accounts --project=$project  keys create ${service_account_name}.json --iam-account $service_account_id
# bind IAM role to service account
IFS=':' read -a array <<< $roles
for role in "${array[@]}"
do
	gcloud projects add-iam-policy-binding $project --member=serviceAccount:$service_account_id --role=$role
done
# validate that service account has two roles
gcloud projects get-iam-policy $project --flatten="bindings[].members" --filter="bindings.members=serviceAccount:$service_account_id" --format="value(bindings.role)"
if [ ! -d $HOME/service-account-dir ] ;then 
	mkdir $HOME/service-account-dir
fi
mv ${service_account_name}.json $HOME/service-account-dir
pushd $HOME/service-account-dir
ls -lrt
echo "finished! the sa create is $service_account_id"
