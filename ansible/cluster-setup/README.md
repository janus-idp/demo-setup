# Assemble with Ansible

A guide to installing `Assemble with Ansible`

## Prerequisites

- Access to an Openshift 4+ deployment and logged in with the CLI
- Install the Following CLIs
  - [ansible](https://www.ansible.com/)/[ansible-galaxy](https://galaxy.ansible.com/)
  - [helm](https://helm.sh/)
    - Please use the version included with your Openshift Deployment
  - [pip3](https://pypi.org/project/pip/)
## Install Packages

1. The Ansible `kubernetes.core` and `community.hashi_vault` collections need to be installed before using this playbook.

    ``` sh
    ansible-galaxy collection install kubernetes.core community.hashi_vault
    ```

1. The `kubernetes`, `openshift`, `hvac`, and `PyYAML` python packages need to be installed before using this playbook.

    ``` sh
    pip3 install --user kubernetes openshift hvac PyYAML
    ```

1. The `helm diff` plugin should to be installed before using this playbook.

    ``` sh
    helm plugin install https://github.com/databus23/helm-diff
    ```

## Configuration

For ease of setup, set the `OPENSHIFT_CLUSTER_INFO` variable for use later.

``` sh
export OPENSHIFT_CLUSTER_INFO=$(echo "$(oc cluster-info | grep -Eo '.cluster(.*?).com')")
```

If you are using Linux environment, set the alias for the following commands to work:

``` sh
alias open="xdg-open"
```
### Set Personal Access Token
Generate a [Personal Access Token](https://github.com/settings/tokens) for GitHub and set the `GITHUB_TOKEN` environment variable. See the official [Backstage Documentation](https://backstage.io/docs/getting-started/configuration#setting-up-a-github-integration) for information on how to create one.
``` sh
export GITHUB_TOKEN=
```

### Create GitHub Organization

Create a new [Github Organization](https://github.com/account/organizations/new?plan=free). This organization will be where the code repositories for the Components created in Backstage will go.

The `GITHUB_ORGANIZATION` environment variable will be set to the name of the Organization. You may also use any organization you are a member of, as long as you have the ability to create new repositories within it.

``` sh
export GITHUB_ORGANIZATION=
```

### Set Up GitHub Application

Create a new GitHub Application to enable the creation of Git WebHooks by the demo.  The required field will be populated, and correct permissions set.

``` sh
open "https://github.com/organizations/$GITHUB_ORGANIZATION/settings/apps/new?name=$GITHUB_ORGANIZATION-tekton-webook&url=https://janus-idp.io/blog&webhook_active=false&public=false&administratio
n=write&checks=write&actions=write&contents=write&statuses=write&vulnerability_alerts=write&dependabot_secrets=write&deployments=write&discussions=write&environ
ments=write&issues=write&packages=write&pages=write&pull_requests=write&repository_hooks=write&repository_projects=write&secret_scanning_alerts=write&secrets=wr
ite&security_events=write&workflows=write&webhooks=write"
```

Set the `GITHUB_APP_ID` environment variable to the App ID of the App you just created. Generate a Private Key for this app and download the private key file.  Set the fully qualified path to the `GITHUB_KEY_FILE` environment variable.

``` sh
export GITHUB_APP_ID=
```
``` sh
export GITHUB_KEY_FILE=
```

Go to the `Install App` table on the left side of the page and install the GitHub App that you create for your organization.

### Create Github OAuth Applications

Create an GitHub OAuth application in order to use GitHub as an Identity Provider for Backstage.

``` sh
open "https://github.com/settings/applications/new?oauth_application[name]=$JANUS_IDP_BOOTSRAP-identity-provider&oauth_application[url]=https://assemble-demo.apps$OPENSHIFT_CLUSTER_INFO&oauth_application[callback_url]=https://keycloak-backstage.apps$OPENSHIFT_CLUSTER_INFO/auth/realms/backstage/broker/github/endpoint"
```

Set the `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` environment variables with the values from the OAuth application.

``` sh
export GITHUB_CLIENT_ID=
```
``` sh
export GITHUB_CLIENT_SECRET=<
```

Create a second GitHub OAuth application to enable Dev Spaces to seamlessly push code changes to the code repository for new Components created in Backstage.  

``` sh
open "https://github.com/settings/applications/new?oauth_application[name]=$JANUS_IDP_BOOTSRAP-dev-spaces&oauth_application[url]=https://devspaces.apps$OPENSHIFT_CLUSTER_INFO&oauth_application[callback_url]=https://devspaces.apps$OPENSHIFT_CLUSTER_INFO/api/oauth/callback"
```

Set the `GITHUB_DEV_SPACES_CLIENT_ID` and `GITHUB_DEV_SPACES_CLIENT_SECRET` environment variables with the values from the OAuth application.

``` sh
export GITHUB_DEV_SPACES_CLIENT_ID=
```
``` sh
export GITHUB_DEV_SPACES_CLIENT_SECRET=
```

### Run the Software Templates Setup Playbook

Fork the [Software Templates](https://github.com/janus-idp/software-templates) repository to your organization. Ensure that the name of the forked repo remains as `software-templates`

Execute the following command to complete setup of the fork. This playbook with customize your fork of the Software Templates repo with relevant information pertaining to your cluster, mimicking the structure of a custom template being used in an enterprise IT environment.

```sh
ansible-playbook ./template.yaml
```
## Install

[Inventory values](inventory/group_vars/all.yml) can be changed, but not required

Run Command:

```sh
ansible-playbook site.yaml -i inventory
```

### FAQ

#### Failed on `Run RHSSO Backstage Helm Chart` during initial run `no matches for kind \"Keycloak\" in version...`

The RHSSO operator may not have completed installation, try rerunning the Ansible Playbook.

#### Failed on `Create Manifests Repo`

Most likely an environment variable is not set, or not set correctly. Validate, delete the Postgres Database Deployment and re-try the playbook.

> Note: If there is an issue post the Postgres database creation please delete the database (or the entire namespace) before attempting to rerun the ansible playbook.

#### Unable to login to Argo Cluster

Admin password can be found on `argocd-cluster` secret. And the username is `admin`
