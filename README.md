# Ansible hello-world-operator

Ansible operator to setup hello-world-operator on Openshift.

Needed objects to create:
* CRD (one per OCP Cluster)
* role (one per Namespace)
* role_binding (one per Namespace)
* service_account (one per Namespace)
* Operator Deployment (one per Namespace)
* Operator headless Service (one per Namespace)
* Operator ServiceMonitor (one per Namespace)
* CRs (N per Namespace)

## Operator SDK setup

You need to go to official [DOC](https://github.com/operator-framework/operator-sdk/blob/master/doc/ansible/user-guide.md), in order to setup minimal `operator-sdk` prerequisites:

- [operator-sdk] version v0.8.1.
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

* In order to create a specific Custom Resource of HelloWorld kind (you can create multiple on same Namespace), you just need to create an specific CR, for example:
 
```bash
apiVersion: hello-world-operator.com/v1alpha1
kind: HelloWorld
metadata:
  name: example
spec:
  helloWorldIsImageLatestTag: "2.0"
  helloWorldIsImageTag: "2.0"
  helloWorldIsImageName: "gcr.io/google-samples/hello-app:2.0"
  helloWorldDcReplicas: 1
  helloWorldDcResourcesRequestsCpu: "50m"
  helloWorldDcResourcesRequestsMemory: "64Mi"
  helloWorldDcResourcesLimitsCpu: "100m"
  helloWorldDcResourcesLimitsMemory: "128Mi"
  helloWorldRouteHosts: "hello-world-example.ocp-cluster.net"
```

* Each HelloWorld CR will contain `name` string on created Openshift objects (to differenciate among different possible HelloWorld CRs inside same namespace).
 
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
create-operator                Create/Update Operator objects (remember to set correct image on deploy/operator.yaml)
delete-operator                Delete Operator objects
create-cr                      Create/Update specific CR
delete-cr                      Delete specific CR
all                            Create all: OCP-project, CRD, Operator, CR
clean                          Clean all resources: CR, Operator, CRD, OCP-project
help                           Print this help
```

## Operator image creation

* Once you have added changes to ansible operator, create new image and push it to registry with:

```bash
$ make docker-update
```

## End-to-end test


* Make sure you have installed `oc` client on your machine, and you are authenticated within a OCP Cluster:

```bash
$ oc login -u admin https://master.ocp-cluster.net:8443
```

* Only on cases where operator or application image may be located on private Docker Registries, you will need to create a Secret with registry credentials, and link that secret with default/builder service_accounts:

```bash
$ oc create secret docker-registry private-quay-auth --docker-server=quay.io --docker-username=user+openshift --docker-password=XXX --docker-email=.
$ oc secrets add serviceaccount/default secrets/private-quay-auth --for=pull
$ oc secrets add serviceaccount/builder secrets/private-quay-auth
```

* Execute `all` target that will create all needed objects (you can overwrite target namespace with `NAMESPACE` var):

```bash
make all
```

* Once tested, execute `clean` target that will delete all created objects (you can overwrite target namespace with `NAMESPACE` var):

```bash
make clean
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
