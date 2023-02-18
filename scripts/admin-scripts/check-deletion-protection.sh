#!/bin/bash 

tmpfile=$(mktemp)
gcloud compute instances --project=development list --format="value(name,zone)" > $tmpfile
while read line
do
	name=$(echo $line| awk '{print $1}')
	zone=$(echo $line| awk '{print $2}')
	echo -n "$name : "
	ssh_state=$(gcloud compute instances describe $name --zone=$zone --format=json | jq '.deletionProtection')
	if [ ! $ssh_state ]; then
		echo
	else
		echo $ssh_state
	fi
	
done < $tmpfile
rm -f $tmpfile
