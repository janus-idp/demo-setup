# rhsso-cluster-auth

Helm chart to Deploy an instance of Red Hat Single Sign on and configure the instance and cluster to leverage the instance for cluster authentication

## Installation

Use the following steps to deploy the chart to an OpenShift cluster

### Prerequisites

1. Install the following Helm Charts
    1. [Patch Operator](../operator/values-patch-operator.yaml)
    2. [RHSSO Operator](../operator/values-rhsso-operator.yaml)

### Deployment

Execute the following command to install the chart to a an OpenShift cluster

```shell
helm upgrade -i rhsso-cluster-auth rhsso-cluster-auth --set openshift.base_domain=$(oc get dns cluster -o jsonpath='{ .spec.baseDomain }') -n rhsso
```
