#!/bin/bash 
PS1='$ ' && clear
[ $# -ne 1 ] && echo "missing project name" && exit 1
GCP_PROJECT=$1 \
  && gcloud services enable cloudasset.googleapis.com --project "${GCP_PROJECT}" \
  && echo Waiting for API enablement to propagate \
  && sleep 10 \
  && gcloud asset search-all-resources --scope "projects/${GCP_PROJECT}" --sort-by 'assetType' \
      --format='table(assetType.basename(), name.basename(), name.scope(projects).segment(0):label=PROJECT_ID, labels)'
