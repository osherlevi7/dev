#!/bin/bash

set -e

# source utils
scripts_folder="$(dirname ${BASH_SOURCE[0]})"
. ./$scripts_folder/utils.sh

# default args
affected_services=
action=
project_id=
branch=
image=$(git rev-parse --abbrev-ref HEAD | sed 's:.*/::')
tag=$(git rev-parse --short HEAD)

# read args from cli
eval "$(read_args "$@")"

parsed_services=("$(echo "${affected_services[*]}" | tr '|' ' ')")
printf "\n${NC}${RED}${parsed_services[*]}${RED}${NC}\n"

if [[ $branch == "main" ]]; then
    env="prod" 
elif [[ $branch == "staging" ]]; then 
    env="staging"
else 
    env="develop"
fi

msg() { printf "\n${2} docker image on service ${NC}${YELLOW}$1${YELLOW}${NC}\n" ; }

for service in ${parsed_services[*]}; do
    path="services/$service/."
    msg $service "${NC}${GREEN}${action}ing"
    #if [[ $service == "emr-fe" ]]; then api="/emr-backend";calls_fe="/calls-frontend";calls_be="/calls-backend"; fi
    if [[ $action == "build" ]]; then
        docker build \
            #--build-arg envfile=".env.$env" \
            --build-arg env=$env \
            -t gcr.io/$project_id/$service:$image-$tag \
            -t gcr.io/$project_id/$service:$image-latest $path || msg $service "${NC}${RED}Failed" | exit 1
    fi

    if [[ $action == "push" ]]; then
        docker push gcr.io/$project_id/$service --all-tags
    fi
done
