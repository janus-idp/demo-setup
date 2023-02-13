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
  
  ```sh
  ansible-galaxy collection install kubernetes.core
  ansible-galaxy collection install community.general
  ```

- Install python packages `kubernetes`, `openshift`, `PyYAML`, and `PyGitub`:

    ```sh
    pip3 install --user kubernetes openshift PyYAML
    pip3 install PyGithub
    ```

### Setup

> Tip: Make sure to `export` the environment variables so Ansible picks them up.

- To enable GitHub integration, generate a Personal Access Token for GitHub and set the `GITHUB_TOKEN` environment variable.
  - See the official [Backstage Documentation](https://backstage.io/docs/getting-started/configuration#setting-up-a-github-integration) for creation instructions
- To enable GitHub as an IDP for backstage then create an GitHub app and set the `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` environment variables.
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

- To enable GitOps configuration, create a Github Organization and set the `GITHUB_ORGANIZATION` environment variable to the name of your [GitOp's Organization](https://github.com/settings/organizations).
  - Or use an organization you are already a member of (ability to create new repositories required)

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
