#!/bin/bash
# Script to retrieve GCP IAM roles, users and serviceaccounts

echo 'project-name,roles/rolename,user:username-and-serviceaccounts' > iamlist.csv
prjs=( $(gcloud projects list | tail -n +2 | awk {'print $1'}) )
for i in "${prjs[@]}"
	do
		echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
		echo "Collecting IAM roles & users for Project: $i"
		echo $(gcloud projects get-iam-policy $i --format="table(bindings)[0]" | sed -e 's/^\w*\ *//'|tail -c +2 |python3 reformat.py $i >> iamlist.csv)	
	done
