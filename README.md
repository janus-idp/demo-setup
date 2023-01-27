# Assemble Platforms

This repository contains automation to install the `assemble platform`, as well as supporting components.

## Getting Started

Step-by-step instructions on getting Assemble running with RHSSO authentication using the included helm charts or by running an ansible playbook found [here](./ansible/README.md).

### Prerequisites

1. Openshift 4.9+
1. Helm 3+

### RHSSO

This section will go over how to:

1. Install the RHSSO Operator
2. Deploy Keycloak, configured with a GitHub App

#### Install RHSSO Operator

Log into your Openshift Cluster and run the following:

```sh
helm upgrade --install rhsso-operator charts/operator -f charts/operator/values-rhsso-operator.yaml -n backstage --create-namespace
```

#### Create GitHub App

Create a [GitHub OAuth Application](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) within the desired organization.  Use the following commands to generate the sample values used for this demo.

Homepage URL:

```sh
echo "https://assemble-demo.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')"
```

Authorization callback URL:

```sh
echo "https://keycloak-backstage.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')/auth/realms/backstage/broker/github/endpoint"
```

Capture the Github Client ID:

```sh
GITHUB_OAUTH_CLIENT_ID=<GITHUB_OAUTH_CLIENTID>
GITHUB_OAUTH_CLIENT_SECRET=<GITHUB_OAUTH_CLIENT_SECRET>
```

#### Deploy the RHSSO Chart

Use the following command to deploy the Helm Chart:

```sh
helm upgrade -i rhsso-backstage charts/rhsso-backstage -n backstage --set keycloak.realm.identityProvider.clientId=$GITHUB_OAUTH_CLIENT_ID --set keycloak.realm.identityProvider.clientSecret=$GITHUB_OAUTH_CLIENT_SECRET --set backstage.host="assemble-demo.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')"
```

Keycloak is now configured and deployed in the `backstage` namespace in OpenShift.

#### Access Keycloak Admin Console

Keycloak Admin Console URL:

```sh
echo $(oc get route keycloak --namespace backstage -o json | jq -r '.spec.host')/auth/admin/
```

Log in to Keycloak's Admin Console using the credentials stored in the `credential-rhsso-backstage` secret.  And navigate to `credentials` tab of the `backstage` client, taking note of the newly generated secret associated with the client.

### Backstage

Configure Backstage and deploy to OpenShift.

#### RHSSO Configuration

Update the `values/rhsso-values.yaml` file with the following content:

```yaml
rhsso:
  # Generate this through the command line using
  # echo "https://keycloak-backstage.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')/auth"
  baseUrl: https://keycloak-backstage.apps.cluster-77bph.77bph.sandbox1927.opentlc.com/auth/
  # The pre-set clientId set by the RHSSO Chart
  clientId: backstage
  # Found in Keycloak admin console, see above
  clientSecret: <KEYCLOAK_CLIENT_SECRET>
  # Enable the backstage plugin
  backstagePluginEnabled: true
```

#### Postgres Configuration

Optionally uncomment the following line in the `postgres` section of `charts/assemble-backstage/values.yaml`.  

> Note: If you choose to leave the password unset, a new password will be generated on every deployment. Which will cause issues on helm upgrades

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

##### Update app-config.yaml

In order for Backstage to push the newly templated application to the chosen repository, an Access Token must be added to `app-config.yaml`.  See the official [Backstage Documentation](https://backstage.io/docs/getting-started/configuration#setting-up-a-github-integration) for information on how to create one.  For the purposes of a demonstration, a Personal Access Token will do.

In `./templates/assemble-config-secret.yaml`:

```yaml
integrations:
    github:
    - host: github.com
      token: <ACCESS_TOKEN>
```

> **_NOTE:_**  The token must be wrapped in single quotes, even when applying the token through an environment variable.
>
#### Deploy the Backstage Chart

Use the following command to deploy the Helm Chart.

```sh
helm upgrade --install assemble-dev . -n assemble --create-namespace
```

Backstage is now configured and deployed in the `assemble` namespace in OpenShift.  Access the UI through the newly deployed Route.  Log in using authentication through GitHub.

### GitOps

For more advanced demos, GitOps can be used to sync templated applications to OpenShift.

```sh
# from the charts/gitops-operator directory
helm upgrade --install argocd . -f values.yaml -n assemble-argocd --create-namespace
```

### Tekton

For more advanced demos, OpenShift Pipelines can be used for CI/CD operations.

```sh
# from the charts/pipelines-operator directory
helm upgrade --install pipelines . -f values.yaml -n assemble-pipelines --create-namespace
```
