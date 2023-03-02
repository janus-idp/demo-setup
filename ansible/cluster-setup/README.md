# Assemble with Ansible

A guide to installing `Assemble with Ansible`

## Prerequisites

- Access to an Openshift 4+ deployment and logged in with the CLI
- Install the Following CLIs
  - [ansible](https://www.ansible.com/)/[ansible-galaxy](https://galaxy.ansible.com/)
  - [helm](https://helm.sh/)
    - Please use the version included with your Openshift Deployment
  - [pip3](https://pypi.org/project/pip/)
- Install ansible's `kubernetes.core` and `community.general` collections:

## Setup

1. The Ansible `kubernetes.core` collections needs to be installed before using this playbook.

    ``` sh
    ansible-galaxy collection install kubernetes.core
    ```

1. The `kubernetes`, `openshift`, and `PyYAML` python packages need to be installed before using this playbook.

    ``` sh
    pip3 install --user kubernetes openshift PyYAML
    ```

1. The `helm diff` plugin should to be installed before using this playbook.

    ``` sh
    helm plugin install https://github.com/databus23/helm-diff
    ```

1. Login to OpenShift
1. If you want to use the GitHub integration, generate a Personal Access Token for GitHub and set the `GITHUB_TOKEN` environment variable.
   See the official [Backstage Documentation](https://backstage.io/docs/getting-started/configuration#setting-up-a-github-integration) for information on how to create one.  For the purposes of a demonstration, a Personal Access Token will do.
1. Create a [Github Organization](https://github.com/settings/organizations) and set the `GITHUB_ORGANIZATION` environment variable to the name of the Organization. You may also use any organization you are a member of, as long as you have the ability to create new repositories within it.
1. In order to create a webhook you'll need to Create a new GitHub Application.  You can do so by clicking [here](https://github.com/organizations/:org/settings/apps/new?url=https://janus-idp.io/blog&webhook_active=false&public=false&administration=write&checks=write&actions=write&code=read&commit_statuses=write&dependabot_alerts=write&dependabot_secrets=write&deployments=write&discussions=write&environments=write&issues=write&packages=write&pages=write&pull_requests=write&reopository_hooks=write&repository_projects=write&secret_scanning_alerts=write&secrets=write&security_events=write&workflows=write&webhooks=write) and replacing the `:org` part of the URL with your organization name before opening.
   - Enter a unique name in the `GitHub App name` field
   - Set the `GITHUB_APP_ID` environment variable to the App ID of the App you just created.
   - Generate a Private Key for this app and download the private key file.  Set the fully qualified path to the `GITHUB_KEY_FILE` environment variable.
   - Go to the `Install App` table on the left side of the page and install the GitHub App that you create for your organization
1. If you want to use GitHub as an IDP for backstage then create an GitHub OAuth app and set the `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` environment variables.
   - Create a [GitHub OAuth Application](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) within the desired organization.  
   - Use the following commands to generate the sample values used for this demo and fill them in using the GitHub UI:

      **Homepage URL:**

        ```sh
          echo "https://assemble-demo.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')"
        ```

      **Authorization Callback URL:**

        ```sh
          echo "https://keycloak-backstage.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')/auth/realms/backstage/broker/github/endpoint"
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