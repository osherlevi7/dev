#!/bin/bash
set -e

echo "Create export/import SQL"

## functions

function usage() {
  echo "$0 <project id> <name> <region name> <action export/import>"
  exit 1
}

function exportdb() {

	for db in $LIST_DB
	do
		echo "if exist old sql file for $name-$db"
		if [ $(gsutil ls  gs://import_export_db/export/$name-$db.sql) ] ; then
			gsutil rm gs://import_export_db/export/$name-$db.sql
			echo "creation $name-$db"
			gcloud sql export sql $name $URI/$action/$name-$db.sql --async --offload --project=$project --database=$db 
		else
			echo "creation $name-$db"
			gcloud sql export sql $name $URI/$action/$name-$db.sql --async --offload --project=$project --database=$db 
		fi
		while [ -z $(gsutil ls  gs://import_export_db/export/$name-$db.sql) ]
		do
			echo "wait till create $name-$db is finished"
			sleep 3
		done
	done
}

function importdb() {
	echo "import"
	gcloud sql import sql $name gs://import_export_db/export/$name-$db.sql --database=$db
}

## main

URI="gs://import_export_db"
LIST_DB="emr diagnosis fub htn mh dm mtb freud_db"

if [ $# -ne 4 ]; then
   usage
else
   project=$1
   name=$2
   region=$3
   action=$4
   case $action in
	   export)
		exportdb;;
           import)
	   	importdb;;
	   *) echo "worng option" ; exit 99;;
   esac
fi
