#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Please provide model name as param"
    exit 1
fi

model_name=$1

dvc_pull_commands=$(grep -rl "dvc pull" | grep "${model_name}")

for dvc_pull_command in ${dvc_pull_commands}; do
    (
        cd $(dirname ${dvc_pull_command})
        dvc pull
    )
done



