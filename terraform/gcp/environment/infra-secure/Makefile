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

bucket?=tf-state-bucket
project_id?=development-gcp-project
cluster_name?=dev-gke
region?=us-east1



.DEFAULT_GOAL := help

help:				## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/${YELLOW}/'

.PHONY: clusters
clusters:    ## list clusters in $project_id
	gcloud container clusters list --project=${project_id} 

.PHONY: connect
connect:    ## connect gke cluster
	$(eval MY_IP := $(shell dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | jq -r '. | @text + "/32"'))
	$(eval LIST_IP := $(shell gcloud container clusters describe ${cluster_name} --format json --zone ${region}-c --project ${project_id} | jq -r '.masterAuthorizedNetworksConfig.cidrBlocks[] | .cidrBlock' | tr '\n' ','))
	gcloud container clusters update ${cluster_name} --master-authorized-networks $(LIST_IP)$(MY_IP) --enable-master-authorized-networks --zone ${region}-c --project ${project_id}
	gcloud container clusters get-credentials ${cluster_name} --region ${region}-c --project ${project_id}

.PHONY: vars
vars:    ## just print default variables
	@echo ${RED} "BUCKET: is ${bucket}"
	@echo ${PURPLE} "PROJECT_ID: is ${project_id}"
	@echo ${BLUE} "CLUSTER_NAME: is ${cluster_name}"
	@echo ${YELLOW} "REGION: is ${region}"

.PHONY: init
init: vars    ## setup the backend of terrform in gcs, require bucket, project_id & cluster_name
	terraform init -backend-config="bucket=${bucket}" -backend-config="prefix=terraform/${project_id}/${cluster_name}/infra/" -reconfigure

.PHONY: validate
validate:    ## vaildate terraform code 
	terraform fmt -recursive
	terraform validate

.PHONY: plan
plan: vars init    ## run dry run command with all relevant variables project_id, cluster_name
	terraform validate
	terraform plan -var project_id=${project_id} -var cluster_name=${cluster_name} -var region=${region}

.PHONY: apply
apply: vars init    ## apply all changes with all relevant variables project_id, cluster_name 
	terraform apply -var project_id=${project_id} -var cluster_name=${cluster_name} -var region=${region} --auto-approve

.PHONY: destroy
destroy: vars init    ## Be careful, this will destroy all relavent resource, should include all relevant variables project_id, cluster_name 
	gcloud container clusters get-credentials ${cluster_name} --zone ${region}-c --project ${project_id}
	terraform destroy -var project_id=${project_id} -var cluster_name=${cluster_name} -var region=${region}
    
all: vars init validate plan apply
