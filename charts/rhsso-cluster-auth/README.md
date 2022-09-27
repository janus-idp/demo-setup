# rhsso-cluster-auth

Helm chart to Deploy an instance of Red Hat Single Sign on and configure the instance and cluster to leverage the instance for cluster authentication

## Installation

Use the following steps to deploy the chart to an OpenShift cluster

### Prerequisites

1. Install the following Helm Charts
    1. [Patch Operator](../operator/values-patch-operator.yaml)
    2. [RHSSO Operator](../operator/values-rhsso-operator.yaml)
       1. Operator deployed to a namespace called `rhsso`
2. Create a [GitHub OAuth Application](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app)

### Deployment

Execute the following command to install the chart to a an OpenShift cluster. Provide the clientId and clientSecret as parameters

```shell
helm upgrade -i rhsso-cluster-auth rhsso-cluster-auth -n rhsso --set keycloak.realm.identityProvider.clientId=<GITHUB_OAUTH_CLIENTID> --set keycloak.realm.identityProvider.clientSecret=<GITHUB_OAUTH_CLIENTSECRET>
```
