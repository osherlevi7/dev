#!/bin/bash
#set -x
echo "Create GCP group instance"
## functions
function usage() {
  echo "$0 <project id> <sub domain name> <domain name> <domain gcp zone name> <environment_type> <gcp region> <git_branch_name>"
  echo "exampls: $0  test domain.ai zone devops us-central1 staging"
  exit 1
}

## main

if [ $# -ne 7 ]; then 
   usage
else
   project=$1
   name=$2
   domain=$3
   domain_zone=$4
   environment=$5
   region=${6:-us-central1}
   branch_name=$7
fi	

echo "#create instance-template"
echo "#---------------------------------------------------------------------------------------------------------------------------"
gcloud compute instance-templates create --project=$project template--${name}-${environment} \
       --no-boot-disk-auto-delete --no-address \
       --boot-disk-size=200 \
       --image-family=ubuntu-pro-2004-lts --image-project=ubuntu-os-pro-cloud \
       --machine-type=e2-standard-8 \
       --labels=environment=${environment} --region=$region \
       --service-account='gcr-sa@.iam.gserviceaccount.com'  \
	--scopes="cloud-platform" \
       --tags=allow-health-check \
       --metadata=branch=${branch_name} \
       --metadata-from-file=startup-script="init-script.sh"

echo "#create instace-group"
echo "#---------------------------------------------------------------------------------------------------------------------------"

gcloud compute instance-groups managed create --project=$project instance-group--${name}-${environment} \
               --size=1 --template=template--${name}-${environment} \
               --base-instance-name="-${environment}" \
               --initial-delay=60 \
               --region=$region --quiet

echo "#Adding a named port to the instance group"
echo "#---------------------------------------------------------------------------------------------------------------------------"
gcloud compute instance-groups set-named-ports --project=$project instance-group--${name}-${environment} \
        --named-ports=http:80,websocket:8080 \
        --region=$region

echo "#create firewall rule for ingress"
echo "#---------------------------------------------------------------------------------------------------------------------------"
gcloud compute firewall-rules create fw-allow-health-check-${name}-${environment} \
    --project=$project \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=allow-health-check \
    --rules=tcp:80,tcp:8080

echo "#Reserving an external IP address"
echo "#---------------------------------------------------------------------------------------------------------------------------"
gcloud compute addresses create lb-vip-${name}-${environment} \
    --project=$project \
    --ip-version=IPV4 \
    --network-tier=PREMIUM \
    --global

echo "# Setting up the load balancer"
echo "#---------------------------------------------------------------------------------------------------------------------------"

echo "# ssl create and attach"
echo "#---------------------------------------------------------------------------------------------------------------------------"

gcloud compute ssl-certificates create www-ssl-cert-${name}-${domain//./-} \
       --domains=${name}.${domain} \
       --global

echo "#create health check for backend service"
echo "#-----------------------------------------"
gcloud compute health-checks create http http-check-${name}-${environment} --port 80

echo "#create health check for websocket backend service"
echo "#---------------------------------------------------------------------------------------------------------------------------"
gcloud compute health-checks create http http-websocket-check-${name}-${environment} --port 8080

echo "# cretae backend service"
echo "#---------------------------------------------------------------------------------------------------------------------------"
gcloud compute backend-services create web-backend-service-${name}-${environment} \
       --project=$project \
       --load-balancing-scheme=EXTERNAL \
       --protocol=HTTP \
       --port-name=http \
       --health-checks=http-check-${name}-${environment} \
       --timeout=300s \
       --global

echo "# cretae websocket backend service"
echo "#---------------------------------------------------------------------------------------------------------------------------"

gcloud compute backend-services create web-socket-backend-service-${name}-${environment} \
       --project=$project \
       --load-balancing-scheme=EXTERNAL \
       --protocol=HTTP \
       --port-name=websocket \
       --health-checks=http-websocket-check-${name}-${environment} \
       --timeout=1800s \
       --global

echo "# attach instance group as the backend to the backend service"
echo "#---------------------------------------------------------------------------------------------------------------------------"
gcloud compute backend-services add-backend web-backend-service-${name}-${environment} \
       --project=$project \
       --instance-group=instance-group--${name}-${environment} \
       --instance-group-region=$region \
       --global

echo "# attach instance group as the backend to the websocket backend service"
echo "#---------------------------------------------------------------------------------------------------------------------------"
gcloud compute backend-services add-backend web-socket-backend-service-${name}-${environment} \
    --project=$project \
    --instance-group=instance-group--${name}-${environment} \
    --instance-group-region=$region \
    --global

echo "# create http url map for the basic backend service"
echo "#---------------------------------------------------------------------------------------------------------------------------"
gcloud compute url-maps create web-https-${name}-lb-${environment} \
       --project=$project \
       --default-service web-backend-service-${name}-${environment} 

echo "#Add path and existing host in path matcher"
echo "#---------------------------------------------------------------------------------------------------------------------------"
 gcloud compute url-maps add-path-matcher web-https-${name}-lb-${environment} \
       --default-service=web-socket-backend-service-${name}-${environment} \
       --path-matcher-name web-socket-https-matcher-${name}-${environment} \
       --path-rules="/ws/*=web-socket-backend-service-${name}-${environment}"

echo "#Setting up an HTTPS frontend"
echo "#---------------------------------------------------------------------------------------------------------------------------"
gcloud compute target-https-proxies create https-proxy-${name}-lb-${environment} \
       --project=$project \
       --url-map=web-https-${name}-lb-${environment} \
       --ssl-certificates=www-ssl-cert-${name}-${domain//./-}

# create rule to route incoming requests to the proxy
gcloud compute forwarding-rules create https-content-rule-${name}-${environment} \
       --project=$project \
       --load-balancing-scheme=EXTERNAL \
       --network-tier=PREMIUM \
       --address=lb-vip-${name}-${environment} \
       --global \
       --target-https-proxy=https-proxy-${name}-lb-${environment} \
       --ports=443

# echo "update the DNS"
# ip=$(gcloud compute addresses describe lb-vip-${name}-${environment} --format="get(address)" --project=dns" --global)
# #gcloud dns record-sets create ${name}.${domain} --type=A --zone=$domain_zone --rrdatas=$ip --ttl=60

echo "Finshed"
