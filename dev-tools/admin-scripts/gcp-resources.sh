#!/bin/bash 
PS1='$ ' && clear
[ $# -ne 1 ] && echo "missing project name" && exit 1
GCP_PROJECT=$1

gcloud services enable cloudasset.googleapis.com --project "${GCP_PROJECT}" 

# && gcloud asset search-all-resources --scope "projects/${GCP_PROJECT}" --sort-by 'assetType' \
#     --format='table(assetType.basename(), name.basename(), name.scope(projects).segment(0):label=PROJECT_ID, labels)'

#resources="run.googleapis.com/Job,container.googleapis.com/Cluster,compute.googleapis.com/Instance,cloudfunctions.googleapis.com/CloudFunction,firestore.googleapis.com/Database,bigquery.googleapis.com/Dataset,bigtableadmin.googleapis.com/Instance,sqladmin.googleapis.com/Instance,spanner.googleapis.com/Instance,file.googleapis.com/Instance,storage.googleapis.com/Bucket,pubsub.googleapis.com/Topic,redis.googleapis.com/Instance"
resources="run.googleapis.com/Job,container.googleapis.com/Cluster,compute.googleapis.com/Instance,cloudfunctions.googleapis.com/CloudFunction,firestore.googleapis.com/Database,bigquery.googleapis.com/Dataset,bigtableadmin.googleapis.com/Instance,sqladmin.googleapis.com/Instance,spanner.googleapis.com/Instance,file.googleapis.com/Instance,storage.googleapis.com/Bucket"
gcloud asset list --project=$GCP_PROJECT --asset-types=$resources --format=json | jq -r 'map({asset_type: .assetType, name: .name}) | (.[0] | to_entries | map(.key)), (.[] | [.[]])| @csv'
