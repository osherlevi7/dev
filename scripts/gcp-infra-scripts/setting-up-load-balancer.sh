#Setting up the load balancer
#1.	Create a health check.

	    gcloud compute health-checks create http http-basic-check \
        --port 80

#2.	Create a backend service
		    gcloud compute backend-services create web-backend-service \
        --load-balancing-scheme=EXTERNAL \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=http-basic-check \
        --global
    
#3.	Add your instance group as the backend to the backend service
		    gcloud compute backend-services add-backend web-backend-service \
        --instance-group=lb-backend-example \
        --instance-group-zone=us-east1-b \
        --global

#4.	For HTTP, create a URL map to route the incoming requests to the default backend service
		    
		gcloud compute url-maps create web-map-http \
        --default-service web-backend-service
    
#5.	For HTTPS, create a URL map to route the incoming requests to the default backend service
		    
		gcloud compute url-maps create web-map-https \
        --default-service web-backend-service
    

#CERTS	
	#Step 1. Create a Google-managed SSL certificate
				
				gcloud compute ssl-certificates create CERTIFICATE_NAME \
				--description=DESCRIPTION \
				--domains=DOMAIN_LIST \
				--global
	#Step 2. For HTTPS, create a target HTTPS proxy to route requests to your URL map (so you also load your certificate in this step.)
				
				   gcloud compute target-https-proxies create https-lb-proxy \
				--url-map=web-map-https \
				--ssl-certificates=www-ssl-cert
	#Step 3. For HTTPS, create a global forwarding rule to route incoming requests to the proxy.
				    
				gcloud compute forwarding-rules create https-content-rule \
				--load-balancing-scheme=EXTERNAL \
				--network-tier=PREMIUM \
				--address=lb-ipv4-1 \
				--global \
				--target-https-proxy=https-lb-proxy \
				--ports=443

#6.	Setting up an HTTP frontend
		#Skip this section for HTTPS load balancers.

	#Step 1. For HTTP, create a target HTTP proxy to route requests to your URL map
	
			    gcloud compute target-http-proxies create http-lb-proxy \
					--url-map=web-map-http
					
	#Step 2.	For HTTP, create a global forwarding rule to route incoming requests to the proxy
		
				    gcloud compute forwarding-rules create http-content-rule \
					--load-balancing-scheme=EXTERNAL \
					--address=lb-ipv4-1 \
					--global \
					--target-http-proxy=http-lb-proxy \
					--ports=80
		

#7.	Enable IAP on the external HTTP(S) load balancer
					gcloud compute backend-services update BACKEND_SERVICE_NAME \
					--iap=enabled,oauth2-client-id=ID,oauth2-client-secret=SECRET \
					--global
