# Ansible hello-world-operator

Ansible hello-world-operator for Openshift.

## Operator SDK setup

You need to go to official [DOC](https://github.com/operator-framework/operator-sdk/blob/master/doc/ansible/user-guide.md), in order to setup minimal `operator-sdk` prerequisites:

- [operator-sdk] version v0.6.0.
- [docker][docker_tool] version 17.03+.
- [kubernetes] version v1.11.0+
- [kubectl][kubectl_tool] version v1.9.0+.
- [oc][oc_tool] version v3.11+
- [ansible][ansible_tool] version v2.6.0+
- [ansible-runner][ansible_runner_tool] version v1.1.0+
- [ansible-runner-http][ansible_runner_http_plugin] version v1.0.0+
- [dep][dep_tool] version v0.5.0+. (Optional if you aren't installing from source)
- [go][go_tool] version v1.11+. (Optional if you aren't installing from source)
- Access to a Openshift v.3.11.0+ cluster.
- A user with administrative privileges in the OpenShift cluster.

## CR example

In order to create a specific Custom Resource of HelloWorld kind (you can create multiple on same Namespace), you just need to create an specific CR:
 
```bash
apiVersion: hello-world-operator.com/v1alpha1
kind: HelloWorld
metadata:
  name: example-helloworld
spec:
  helloWorldNameSpaceName: "hello-world"
  helloWorldIsImageLatestTag: "2.0"
  helloWorldIsImageTag: "2.0"
  helloWorldIsImageName: "gcr.io/google-samples/hello-app:2.0"
  helloWorldDcReplicas: 1
  helloWorldDcResourcesRequestsCpu: "50m"
  helloWorldDcResourcesRequestsMemory: "64Mi"
  helloWorldDcResourcesLimitsCpu: "100m"
  helloWorldDcResourcesLimitsMemory: "128Mi"
  helloWorldRouteHosts: "hello-world-example.apps.ocp-40.net"
```

Each HelloWorld CR will contain `name` string on created Openshift objects (to differenciate among different possible HelloWorld CRs inside same namespace).
 
## Usage

```bash
$ make
docker-build                   Build operator Docker image
docker-push                    Push operator Docker image to remote registry
docker-update                  Build and Push operator Docker image to remote registry
create-project                 Create OCP project for the operator
switch-project                 Swith to OCP project for the operator
delete-project                 Delete OCP project for the operator
create-crd                     Create Operator CRD
delete-crd                     Delete Operator CRD
create-operator                Create Operator objects (remember to set correct image on deploy/operator.yaml)
update-operator                Update Operator main object
delete-operator                Delete Operator objects
create-cr                      Create specific CR
update-cr                      Update specific CR
delete-cr                      Delete specific CR
all                            Create all: OCP project, CRD, Operator, CR
clean                          Clean all resources: CR, Operator, CRD, OCP project
help                           Print this help
```

[operator-sdk]:https://github.com/operator-framework/operator-sdk
[docker_tool]:https://docs.docker.com/install/
[ansible_tool]:https://docs.ansible.com/ansible/latest/index.html
[ansible_runner_tool]:https://ansible-runner.readthedocs.io/en/latest/install.html
[ansible_runner_http_plugin]:https://github.com/ansible/ansible-runner-http
[dep_tool]:https://golang.github.io/dep/docs/installation.html
[go_tool]:https://golang.org/
[kubernetes]:https://kubernetes.io/
[kubectl_tool]:https://kubernetes.io/docs/tasks/tools/install-kubectl/
[oc_tool]:https://docs.okd.io/3.11/cli_reference/get_started_cli.html#cli-reference-get-started-cli
