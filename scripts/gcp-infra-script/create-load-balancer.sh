#!/bin/bash
set -x
echo "Create GCP group instance"
## functions
function usage() {
  echo "$0 <project id> <name> <domain name> <environment_type>"
  exit 1
}
## main
if [ $# -ne 4 ]; then 
   usage
else
   project=$1
   name=$2
   domain=$3
   environment=$4
   region="us-central1"
fi	
#create firewall rule for ingress
gcloud compute firewall-rules create fw-allow-health-check-${name} \
    --project=$project \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=allow-health-check \
    --rules=tcp:80 

#reserve ips 
gcloud compute addresses create lb-ipv4-${name} \
    --project=$project \
    --ip-version=IPV4 \
    --network-tier=PREMIUM \
    --global

#create health check for backend service
gcloud compute health-checks create http http-basic-check-${name} --port 80

# cretae backend service 
gcloud compute backend-services create web-backend-service-${name} \
       --project=$project \
       --load-balancing-scheme=EXTERNAL \
       --protocol=HTTP \
       --port-name=http \
       --health-checks=http-basic-check-${name} \
       --global

# attach instance group as the backend to the backend service
gcloud compute backend-services add-backend web-backend-service-${name} \
       --project=$project \
       --instance-group=instance-group--${name} \
       --instance-group-region=$region \
       --global

# create url map for backend service
gcloud compute url-maps create web-map-https-${name} \
       --project=$project \
       --default-service web-backend-service-${name}

# ssl create and attach
gcloud compute ssl-certificates create certificate-${name} \
       --description="certificate for $domain" \
       --domains=$domain \
       --global

#setup https frontend
gcloud compute target-https-proxies create https-lb-proxy-${name} \
       --project=$project \
       --url-map=web-map-https-${name} \
       --ssl-certificates=certificate-${name}

# create rule to route incoming requests to the proxy
gcloud compute forwarding-rules create https-content-rule \
       --project=$project \
       --load-balancing-scheme=EXTERNAL \
       --network-tier=PREMIUM \
       --address=lb-ipv4-${name} \
       --global \
       --target-https-proxy=https-lb-proxy-${name} \
       --ports=443

echo "Finshed"
