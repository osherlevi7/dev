#!/bin/bash
# Trigger an error if non-zero exit code is encountered
set -e 
# Start the application as the non-root user
exec gunicorn -k uvicorn.workers.UvicornWorker -c gunicorn_conf.py main:app