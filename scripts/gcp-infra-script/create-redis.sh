#!/bin/bash
echo Creating Redis
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
echo "Create Redis instance"

gcloud redis instances create \
   --project=$project redis-$name --size=1 --region=$region \
	--redis-version=redis_6_x --tier=BASIC --connect-mode=DIRECT_PEERING
