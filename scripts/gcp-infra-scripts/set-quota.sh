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

gcloud alpha services quota update --service=example.googleapis.com --consumer=projects/12321 --metric=example.googleapis.com/default_requests --unit=1/min/{project} --dimensions=regions=us-central1 --dimensions=zones=us-central1-c --value=360 --force
