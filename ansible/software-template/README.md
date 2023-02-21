# Customize Software Templates

These steps will customize the Janus software templates for use within your OpenShift cluster.  

## Prerequisites

- Access to an Openshift 4+ deployment and logged in with the CLI
- A GitHub Organization for which you have access to

## Setup

1. Set the `GITHUB_ORGANIZATION` environment variable to the name of your organization.

    ``` sh
    export GITHUB_ORGANIZATION= #set your Git Hub org name here
    ```

2. Fork the [Software Templates](https://github.com/janus-idp/software-templates) repository to your organization.

3. Run the ansible playbook to complete setup. This playbook with customize your fork of the Software Templates repo with relevant information pertaining to your cluster, mimicking the structure of a custom template being used in an enterprise IT environment.

```sh
ansible-playbook ./site.yaml
```

### FAQ

#### Failed on `Run RHSSO Backstage Helm Chart` during initial run `no matches for kind \"Keycloak\" in version...`

The RHSSO operator may not have completed installation, try rerunning the Ansible Playbook.

#### Failed on `Create Manifests Repo`

Most likely an environment variable is not set, or not set correctly. Validate, delete the Postgres Database Deployment and re-try the playbook.

> Note: If there is an issue post the Postgres database creation please delete the database (or the entire namespace) before attempting to rerun the ansible playbook.

#### Unable to login to Argo Cluster

Admin password can be found on `argocd-cluster` secret. And the username is `admin`