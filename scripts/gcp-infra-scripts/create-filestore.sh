#!/bin/bash
set -e
echo "Create NFS Store"
## functions
function usage() {
  echo "$0 <project id> <name> <region name>"
  exit 1
}
## main
if [ $# -ne 3 ]; then
   usage
else
   project=$1
   name=$2
   region=$3
fi
# create service account in project
gcloud filestore  instances --project=$project create nfs-$name --region=$region \
	             --tier=BASIC_HDD --file-share=name="compose",capacity=1TB \
		     --network=name="default"
