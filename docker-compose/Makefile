ifneq (,$(wildcard ./.env))
    include .env
		export HOSTNAME=$(shell hostname)
    export
endif

.PHONY: slack gcr-login pull logs up down ps images restart

slack:
		curl -d "text=GCP VM ${HOSTNAME} is $(state) by ${USER}" -d "channel=${SLACK_CHANNEL_ID}" -H "Authorization: Bearer ${SLACK_TOKEN}" -X POST https://slack.com/api/chat.postMessage

gcr-login:
		gcloud auth activate-service-account sa@project.iam.gserviceaccount.com --key-file=/path/sa-key.json
		gcloud config set project artifactory
		gcloud auth configure-docker us-docker.pkg.dev

pull:
		export LD_LIBRARY_PATH=/usr/local/lib && \
		docker-compose pull

logs:
		docker-compose logs -f --tail=100

up:
		$(MAKE) slack state="up ✌️"
		docker-compose up --detach

down:
		$(MAKE) slack state="down 💩"
		docker-compose down

ps:
		docker-compose ps

images:
		docker-compose images

restart:
		docker-compose down
		sleep 5
		docker-compose up -d

