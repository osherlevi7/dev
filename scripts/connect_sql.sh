#!/bin/bash

set -e
function usage() {
  echo "$0 <db_internal_ip> <required_port> <project> <zone> <tunnel>"
  exit 1
}


if [ $# -ne 5 ]; then
   usage
else

    # source utils
    scripts_folder="$(dirname ${BASH_SOURCE[0]})"
    . ./$scripts_folder/utils.sh

    # default args
    ip=$1
    port=$2
    project=$3
    zone=$4
    tunnel=$5

    # read args from cli
    eval "$(read_args "$@")"

    gcloud compute  ssh --ssh-flag="-L $port:$ip:5432" $tunnel --zone=$zone --project=$project
fi