.PHONY: docker-build docker-push docker-update create-project switch-project delete-project create-crd delete-crd create-operator delete-operator create-cr delete-cr all clean help

.DEFAULT_GOAL := help

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
THISDIR_PATH := $(patsubst %/,%,$(abspath $(dir $(MKFILE_PATH))))

IMAGE ?= slopezz/ansible-hello-world-operator
VERSION ?= v1.1.0
NAMESPACE ?= example

docker-build: ## Build operator Docker image
	operator-sdk build $(IMAGE):$(VERSION)

docker-push: ## Push operator Docker image to remote registry
	docker push $(IMAGE):$(VERSION)

docker-update: docker-build docker-push ## Build and Push operator Docker image to remote registry

create-project: ## Create OCP project for the operator
	oc new-project $(NAMESPACE) || true
	oc label namespace $(NAMESPACE) monitoring=enabled || true
	oc project $(NAMESPACE)

switch-project: ## Swith to OCP project for the operator
	oc project $(NAMESPACE)

delete-project: ## Delete OCP project for the operator
	oc delete --force project $(NAMESPACE) || true

create-crd: switch-project ## Create Operator CRD
	oc create -f deploy/crds/crd.yaml || true

delete-crd: switch-project ## Delete Operator CRD
	oc delete -f deploy/crds/crd.yaml || true

create-operator: switch-project ## Create/Update Operator objects (remember to set correct image on deploy/operator.yaml)
	oc apply -f deploy/service_account.yaml
	oc apply -f deploy/role.yaml
	oc apply -f deploy/role_binding.yaml
	oc apply -f deploy/operator.yaml
	oc apply -f deploy/operator-service.yaml
	oc apply -f deploy/operator-servicemonitor.yaml

delete-operator: switch-project ## Delete Operator objects
	oc delete -f deploy/operator-servicemonitor.yaml || true
	oc delete -f deploy/operator-service.yaml || true
	oc delete -f deploy/operator.yaml || true
	oc delete -f deploy/role_binding.yaml || true
	oc delete -f deploy/role.yaml || true
	oc delete -f deploy/service_account.yaml || true

create-cr: switch-project ## Create/Update specific CR
	oc apply -f deploy/crds/cr.yaml

delete-cr: switch-project ## Delete specific CR
	oc delete -f deploy/crds/cr.yaml || true

all: create-project create-crd create-operator create-cr ## Create all: OCP-project, CRD, Operator, CR

clean: delete-cr delete-operator delete-crd delete-project ## Clean all resources: CR, Operator, CRD, OCP-project

help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
