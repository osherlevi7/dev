# TERRAFORM INSTALL
version  ?= "0.14.11"
os       ?= $(shell uname|tr A-Z a-z)
ifeq ($(shell uname -m),x86_64)
  arch   ?= "amd64"
endif
ifeq ($(shell uname -m),i686)
  arch   ?= "386"
endif
ifeq ($(shell uname -m),aarch64)
  arch   ?= "arm"
endif

# INTERNAL VARIABLES
# Read all subsquent tasks as arguments of the first task
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(args) $(RUN_ARGS):;@:)
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
landscape   := $(shell command -v landscape 2> /dev/null)
terraform   := $(shell command -v terraform 2> /dev/null)
debug       :=

# MAKEFILE ARGUMENTS
ifndef terraform
  install ?= "true"
endif
ifeq ("$(upgrade)", "true")
  install ?= "true"
endif

# define standard colors
ifneq (,$(findstring xterm,${TERM}))
	BLACK        := $(shell tput -Txterm setaf 0)
	RED          := $(shell tput -Txterm setaf 1)
	GREEN        := $(shell tput -Txterm setaf 2)
	YELLOW       := $(shell tput -Txterm setaf 3)
	LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
	PURPLE       := $(shell tput -Txterm setaf 5)
	BLUE         := $(shell tput -Txterm setaf 6)
	WHITE        := $(shell tput -Txterm setaf 7)
	RESET := $(shell tput -Txterm sgr0)
else
	BLACK        := ""
	RED          := ""
	GREEN        := ""
	YELLOW       := ""
	LIGHTPURPLE  := ""
	PURPLE       := ""
	BLUE         := ""
	WHITE        := ""
	RESET        := ""
endif
# set target color

bucket?=tf-state
project_id?=project-development
sub_domain?=monitoring.app
region?=us-east1
mail='osher.levi7@gmail.com'


.DEFAULT_GOAL := help

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/${YELLOW}/'

.PHONY: vars
vars: ## just print default variables
	@echo ${RED} "BUCKET: is ${bucket}"
	@echo ${PURPLE} "PROJECT_ID: is ${project_id}"
	@echo ${BLUE} "SUB_DOMAIN: is ${sub_domain}"
	@echo ${YELLOW} "REGION: is ${region}"
	@echo ${GREEN} "USER OR Group: is ${mail}"

.PHONY: init
init: vars ## setup the backend of terrform in gcs, require bucket, project_id 
	terraform init -backend-config="bucket=${bucket}" -backend-config="prefix=terraform/${project_id}/monitoring/" -reconfigure

.PHONY: validate
validate: ## vaildate terraform code 
	terraform fmt -recursive
	terraform validate

.PHONY: plan
plan: vars ## run dry run command with all relevant variables project_id, sub_domain
	terraform validate
	terraform plan -var project_id=${project_id}  -var sub_domain=${sub_domain} -var region=${region}

.PHONY: apply
apply: vars ## apply all changes with all relevant variables project_id, sub_domain
	terraform apply -var project_id=${project_id} -var sub_domain=${sub_domain} -var region=${region} --auto-approve

.PHONY: destroy
destroy: vars ## Be careful, this will destroy all relavent resource, should include all relevant variables project_id, sub_domain
	terraform destroy -var project_id=${project_id} -var sub_domain=${sub_domain} -var region=${region}

.PHONY: access
access: ## Access Grafana Dashboard, Adding users and groups permissions to LB resource
	gcloud iap web add-iam-policy-binding \
	--project=${project_id} \
	--resource-type=backend-services \
	--member=${mail} \
	--service='grafana-lb-backend-default' \
	--role='roles/iap.httpsResourceAccessor'
    
plan: vars init validate plan
all: vars init validate plan apply
