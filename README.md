# Assemble Platforms

This repository contains automation to install the `assemble platform`, as well as supporting components.

## Getting Started

Step-by-step instructions on getting Assemble running with RHSSO authentication using the included helm charts


> **_NOTE:_** For an even faster start try running the ansible playbook found [here](./ansible/README.md).

### Prerequisites

1. Openshift 4.9+
1. Helm 3+

### RHSSO

This section will go over how to:

1. Install the RHSSO Operator
2. Deploy Keycloak using a GitHub Client

#### Install RHSSO Operator

Log into your Openshift Cluster and run the following:

```sh
helm upgrade --install rhsso-operator charts/operator -f charts/operator/values-rhsso-operator.yaml -n backstage --create-namespace
```

#### Create GitHub Client App

Create a [GitHub OAuth Application](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) within the desired organization.  Use the following commands to generate the sample values used for this demo.

Homepage URL:

```sh
HOMEPAGE_URL="https://assemble-demo.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')"
```

Authorization callback URL:

```sh
AUTHORIZATION_URL="https://keycloak-backstage.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')/auth/realms/backstage/broker/github/endpoint"
```

Capture the Github Client ID:

```sh
GITHUB_OAUTH_CLIENT_ID=<GITHUB_OAUTH_CLIENTID>

GITHUB_OAUTH_CLIENT_SECRET=<GITHUB_OAUTH_CLIENT_SECRET>
```

#### Deploy the RHSSO Chart

Use the following command to deploy the Helm Chart:

```sh
helm upgrade -i rhsso-backstage charts/rhsso-backstage -n keycloak --set keycloak.realm.identityProvider.clientId=$GITHUB_OAUTH_CLIENT_ID --set keycloak.realm.identityProvider.clientSecret=$GITHUB_OAUTH_CLIENT_SECRET --set backstage.host="$HOMEPAGE_URL"
```

Keycloak is now configured and deployed in the `backstage` namespace in OpenShift.

#### Access Keycloak Admin Console

Keycloak Admin Console URL:

```sh
echo $(oc get route keycloak --namespace backstage -o json | jq -r '.spec.host')/auth/admin/
```

Log in to Keycloak's Admin Console using the credentials stored in the `credential-rhsso-backstage` secret.  And navigate to `credentials` tab of the `backstage` client, taking note of the newly generated secret associated with the client (this will be used later).

### Backstage

Configure Backstage and deploy to OpenShift.

#### RHSSO Configuration

Update the `values/rhsso-values.yaml` file with the following content:

```yaml
rhsso:
  # Generate this through the command line using
  # echo "https://keycloak-backstage.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')/auth"
  baseUrl: <BASE_URL>
  # The pre-set clientId set by the RHSSO Chart
  clientId: backstage
  # Found in Keycloak admin console, see note below
  clientSecret: <KEYCLOAK_CLIENT_SECRET>
  # Enable the backstage plugin
  backstagePluginEnabled: true
```

> **_NOTE:_** `KEYCLOAK_CLIENT_SECRET` can be found in the KeyCloak UI by navigating to `Clients -> Backstage -> Credentials`

#### Postgres Configuration

Optionally uncomment the following line in the `postgres` section of `charts/assemble-backstage/values.yaml`.  

> **_NOTE:_** If you choose to leave the password unset, a new password will be generated on every deployment. Which will cause issues on helm upgrades

```yaml
postgres:
  database_password: "somepassword"
```

#### General Backstage Configuration

Fill in the companyName and baseUrl in the `backstage` section of `values/rhsso-values.yaml` updating the following:

```yaml
backstage:
  companyName: "<UPDATE_ME>"
  port: 7007
  # Generate this through the command line using
  # echo "https://assemble-demo.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')"
  baseUrl: "<BASE_URL>"
```

#### Optional: Sample Template

Deploying the Helm Chart at this point will result in a fully functional instance of Backstage.  You may wish to add a Template to the catalog for demonstration purposes.

##### Add Template

Add a sample template to the `backstage.catalog` section of `values/rhsso-values.yaml`.

```yaml
backstage:
  catalog:
    #  Add Template to the allowed types
    rules:
      - allow: [Component, System, API, Resource, Location, Template]
    locations:
      # Add reference to sample template
      - type: url
        target: https://github.com/janus-idp/software-templates/blob/main/scaffolder-templates/quarkus-web-template/template.yaml
```

For a list of additional templates and information on the Quarkus template referenced here, visit the [Janus-IDP](https://github.com/janus-idp/software-templates) organization.

##### Integrate Github

A Git Token must be included in the `app-config.yaml` in order to login to the Assemble Platform.

See the official [Backstage Documentation](https://backstage.io/docs/getting-started/configuration#setting-up-a-github-integration) for more information on how to create one.  For the purposes of a demonstration, a Personal Access Token will do.

Add the following content to `values/rhsso-values.yaml` in order to include the git token to the config:

```yaml
github:
  enabled: true
  token: <ACCESS_TOKEN>
```

> **_NOTE:_**  The token must be wrapped in single quotes, even when applying the token through an environment variable.

#### Deploy the Backstage Chart

Use the following command to deploy the Helm Chart.

```sh
helm upgrade -i assemble-dev charts/assemble-backstage -n assemble --create-namespace -f values/rhsso-values.yaml
```

Backstage is now configured and deployed in the `assemble` namespace in OpenShift.  Access the UI through the newly deployed Route.  Log in using authentication through GitHub:

```sh
echo $(oc get route assemble-dev --namespace assemble -o json | jq -r '.spec.host')
```

### GitOps

For more advanced demos, GitOps can be used to sync templated applications to OpenShift.

```sh
helm upgrade --install charts/gitops-operator/argocd . -n assemble-argocd --create-namespace
```

### Tekton

For more advanced demos, OpenShift Pipelines can be used for CI/CD operations.

```sh
helm upgrade --install pipelines charts/pipelines-operator -n assemble-pipelines --create-namespace
```
