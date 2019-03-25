.PHONY: docker-build docker-push docker-update create-project switch-project delete-project create-crd delete-crd create-operator delete-operator update-operator create-cr update-cr delete-cr all clean help

.DEFAULT_GOAL := help

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
THISDIR_PATH := $(patsubst %/,%,$(abspath $(dir $(MKFILE_PATH))))

IMAGE ?= slopezz/hello-world-operator
VERSION ?= v0.0.20
NAMESPACE ?= example-hello-world

docker-build: ## Build operator Docker image
	operator-sdk build $(IMAGE):$(VERSION)

docker-push: ## Push operator Docker image to remote registry
	docker push $(IMAGE):$(VERSION)

docker-update: docker-build docker-push ## Build and Push operator Docker image to remote registry

create-project: ## Create OCP project for the operator
	oc new-project $(NAMESPACE)
	oc project $(NAMESPACE)

switch-project: ## Swith to OCP project for the operator
	oc project $(NAMESPACE)

delete-project: ## Delete OCP project for the operator
	oc delete --force project $(NAMESPACE) || true

create-crd: switch-project ## Create Operator CRD
	oc create -f deploy/crds/hello-world-operator_v1alpha1_helloworld_crd.yaml

delete-crd: switch-project ## Delete Operator CRD
	oc delete -f deploy/crds/hello-world-operator_v1alpha1_helloworld_crd.yaml

create-operator: switch-project ## Create Operator objects (remember to set correct image on deploy/operator.yaml)
	oc create -f deploy/service_account.yaml
	oc create -f deploy/role.yaml
	oc create -f deploy/role_binding.yaml
	oc create -f deploy/operator.yaml

update-operator: switch-project ## Update Operator main object
	oc apply -f deploy/operator.yaml

delete-operator: switch-project ## Delete Operator objects
	oc delete -f deploy/operator.yaml
	oc delete -f deploy/role_binding.yaml
	oc delete -f deploy/role.yaml
	oc delete -f deploy/service_account.yaml

create-cr: switch-project ## Create specific CR
	oc create -f deploy/crds/hello-world-operator_v1alpha1_helloworld_cr.yaml

update-cr: switch-project ## Update specific CR
	oc apply -f deploy/crds/hello-world-operator_v1alpha1_helloworld_cr.yaml

delete-cr: switch-project ## Delete specific CR
	oc delete -f deploy/crds/hello-world-operator_v1alpha1_helloworld_cr.yaml

all: create-project create-crd create-operator create-cr ## Create all: OCP project, CRD, Operator, CR

clean: delete-cr delete-operator delete-crd delete-project ## Clean all resources: CR, Operator, CRD, OCP project

help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
