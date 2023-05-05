#!/bin/bash

set -e

migrate_db_folder="${BASH_SOURCE[0]%/*}/"
PG_USER=$(id -un)

# source venv
. ./venv/bin/activate

# start postgres service
pushd "$migrate_db_folder" &> /dev/null || exit 1
docker compose up -d

python migrate_db.py --ex_sql develop --im_sql localhost --ex_databases "$@"

popd &> /dev/null || exit 1
