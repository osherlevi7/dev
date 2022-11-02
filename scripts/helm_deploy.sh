#!/bin/bash

# source utils
scripts_folder="$(dirname ${BASH_SOURCE[0]})"
. ./$scripts_folder/utils.sh

affected_services=

for service in $affected_services; do
    echo $service
    helm upgrade --install -f "services/$service/values.yaml" helm
done
