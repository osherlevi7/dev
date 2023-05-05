#!/bin/bash
set -e

if [ "$GCR" == "yes" ]  ; then 
   date
   docker login -u oauth2accesstoken -p "$(gcloud auth print-access-token)" https://gcr.io
   if [ -f /root/.docker/config.json ] ; then
	   cp /root/.docker/config.json /config.json
   fi
fi

