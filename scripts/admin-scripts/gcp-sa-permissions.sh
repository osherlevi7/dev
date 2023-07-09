#!/bin/bash
# Script to retrieve GCP IAM roles, users and serviceaccounts

echo 'service-account,project,roles' > /tmp/salist.csv
prjs=( $(gcloud projects list | tail -n +2 | awk {'print $1'}) )
for p in "${prjs[@]}"
	do
		#echo "Collecting SA for Project: $p"
		sas=($(gcloud iam service-accounts list --format="value(email)" --project $p))
		for sa in "${sas[@]}" 
		do
			#echo "Collecting IAM roles for SA: $sa"
			roles=$(gcloud projects get-iam-policy $p  \
			--flatten="bindings[].members" \
			--format='table[no-heading](bindings.role)' \
			--filter="bindings.members:$sa" | tr '\n' ' ')
			echo "$sa,$roles,$p" >> /tmp/salist.csv
		done
		
	done
