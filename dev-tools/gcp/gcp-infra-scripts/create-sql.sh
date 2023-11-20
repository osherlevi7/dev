#!/bin/bash
set -e
echo "Create GCP SQL"
## functions
function usage() {
  echo "$0 <project id> <name> <region name> <H/A yes/no>"
  exit 1
}
## main
if [ $# -ne 4 ]; then
   usage
else
   project=$1
   name=$2
   region=$3
   ha=$4
   if [ $ha == "yes" ] ; then
	   ha_cmd="availability-type=REGIONAL"
   fi
fi
# create service account in project
echo "Create SQL instance"
password=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12 ; echo '')
echo $password
if [ -z $(gcloud sql instances describe sql-$name --project=$project --format=json | jq -r .serverCaCert.instance) ] ; then
gcloud sql instances --project=$project create sql-$name --region=$region \
	             --availability-type=zonal --activation-policy=always --no-assign-ip \
		     --backup --retained-backups-count=7 --backup-start-time=20:00 \
		     --enable-point-in-time-recovery --retained-transaction-log-days=7 \
		     --enable-point-in-time-recovery --storage-size=50 --storage-type=SSD \
		     --insights-config-query-insights-enabled --insights-config-query-string-length=1024 \
		     --insights-config-record-application-tags --insights-config-record-client-address \
		     --replication=synchronous --storage-auto-increase --cpu=2 --memory=13312MB \
		     --network=default $ha_cmd \
		     --database-version=POSTGRES_14 --root-password=${password}

fi

echo "Create secret"
if [ -z $(gcloud secrets describe  sql-secret-${name} --project=$project --format=json| jq -r .name) ] ; then 
   gcloud secrets create sql-secret-$name --project=$project --replication-policy="automatic"
   echo $password | gcloud secrets --project=$project versions add sql-secret-$name --data-file=-
fi
echo "Change password for DB"
gcloud sql users set-password postgres --project=$project --instance=sql-$name --password=$password
echo "Create databases"
list_db="a b c d"
for db in $list_db
do
    gcloud sql databases create $db \
       --project=$project \
       --instance=sql-$name \
       --charset=UTF8 \
       --collation=en_US.UTF8
done
