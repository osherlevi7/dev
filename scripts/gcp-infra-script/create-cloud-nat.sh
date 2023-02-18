#!/bin/bash

gcloud compute routers nats create NAT_CONFIG \
    --router=NAT_ROUTER \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges \
    --enable-logging
