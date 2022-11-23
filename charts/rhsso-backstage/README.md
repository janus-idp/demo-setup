# rhsso-backstage

Helm chart to Deploy an instance of Red Hat Single Sign on and configure the instance to support acting as an identity provider for Backstage

## Installation

Use the following steps to deploy the chart to an OpenShift cluster

### Prerequisites

1. Install the RHSSO Operator.  It is deployed to a namespace called `backstage`
    ```shell
    # from within the charts/operator directory
    helm upgrade --install rhsso-operator . -f ./values-rhsso-operator.yaml -n backstage --create-namespace
    ```
2. Create a [GitHub OAuth Application](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) within the desired GitHub organization
    1. Configure the Redirect URL using the format: `https://<KEYCLOAK_HOST>/auth/realms/<REALM>/broker/github/endpoint`

### Deployment

Execute the following command to install the chart to a an OpenShift cluster. Provide the clientId and clientSecret as parameters

```shell
helm upgrade -i rhsso-backstage . -n backstage --set keycloak.realm.identityProvider.clientId=<GITHUB_OAUTH_CLIENTID> --set keycloak.realm.identityProvider.clientSecret=<GITHUB_OAUTH_CLIENTSECRET> --set backstage.host=<BACKSTAGE_HOST>
```
