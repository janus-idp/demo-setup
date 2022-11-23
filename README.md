# Assemble Platforms
This repository contains automation to install the assemble platform including supporting components. 

## Getting Started
Step-by-step instructions on getting Assemble running with RHSSO authentication using the included helm charts.

### Prerequisites
1. Clone this repository
2. Log in to the OpenShift

### RHSSO
Install the RHSSO Operator and deploy Keycloak, configured with a GitHub App.  The following commands must be run from within the [rhsso-backstage](./charts/rhsso-backstage) directory.

#### Install RHSSO Operator
`helm upgrade --install rhsso-operator . -f ./values-rhsso-operator.yaml -n backstage --create-namespace`

#### Create GitHub App
Create a [GitHub OAuth Application](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) within the desired organization.  Use the following commands to generate the sample values used for this demo.

Homepage URL:

`echo "https://assemble-demo.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')"`

Authorization callback URL:

`echo "https://keycloak-backstage.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')/auth/realms/backstage/broker/github/endpoint"`

#### Deploy the RHSSO Chart
Use the following command to deploy the Helm Chart, replacing the relevant values with those from the GitHub App.

`helm upgrade -i rhsso-backstage . -n backstage --set keycloak.realm.identityProvider.clientId=<GITHUB_OAUTH_CLIENTID> --set keycloak.realm.identityProvider.clientSecret=<GITHUB_OAUTH_CLIENTSECRET> --set backstage.host="assemble-demo.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')"`

Keycloak is now configured and deployed in the `backstage` namespace in OpenShift.
#### Access Keycloak Admin Console
Log in to Keycloak using the credentials stored in the `credential-rhsso-backstage` Secret.  Navigate to `credentials` tab of the `backstage` client, taking note of the newly generated secret associated with the client.

### Backstage
Configure Backstage and deploy to OpenShift.  The following commands must be run from within the [assemble-backstage](./charts/assemble-backstage) directory.

#### OAuth Configuration
Update the `oauth` section of `values.yaml` to the following:
```
oauth:
  enabled: true
  # The pre-set clientId set by the RHSSO Chart
  clientId: backstage
  # Found in Keycloak admin console, see above
  clientSecret: <KEYCLOAK_CLIENT_SECRET>
  # Generate this through the command line using
  # echo "https://keycloak-backstage.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')/auth/realms/backstage"
  issuerUrl: https://<KEYCLOAK_HOST>/auth/realms/<REALM>
```
#### Postgres Configuration
Uncomment the following line in the `postgres` section of `values.yaml`.  If the password is not set, a new password will be generated on every deployment, causing an error and preventing pod startup on subsequent helm upgrades.
```
postgres:
  database_password: "somepassword"
```

#### General Backstage Configuration
Fill in the companyname and baseUrl in the `backstage` section of `values.yaml`
```
backstage:
  companyname: "<COMPANY_NAME>"
  port: 7007
  # Generate this through the command line using
  # echo "https://assemble-demo.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')"
  baseUrl: "<BASE_URL>"
```
#### Optional: Sample Template
Deploying the Helm Chart at this point will result in a fully functional instance of Backstage.  You may wish to add a Template to the catalog for demonstration purposes.

##### Add Template
Add a sample template to the `backstage.catalog` section of `values.yaml`.
```
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
```
integrations:
    github:
    - host: github.com
        token: <ACCESS_TOKEN>
```

#### Deploy the Backstage Chart
Use the following command to deploy the Helm Chart.

`helm upgrade --install assemble-dev . -n assemble --create-namespace`

Backstage is now configured and deployed in the `assemble` namespace in OpenShift.  Access the UI through the newly deployed Route.  Log in using authentication through GitHub.

### GitOps
For more advanced demos, GitOps can be used to sync templated applications to OpenShift.

```
# from the charts/gitops-operator directory
helm upgrade --install argocd . -f values.yaml -n assemble-argocd --create-namespace
```

### Tekton
For more advanced demos, OpenShift Pipelines can be used for CI/CD operations.

```
# from the charts/pipelines-operator directory
helm upgrade --install pipelines . -f values.yaml -n assemble-pipelines --create-namespace
```