# Getting Started

## Prerequisite

- Access to an Openshift 4+ deployment and logged in with the CLI
- Install the Following CLIs
  - [ansible](https://www.ansible.com/)/[ansible-galaxy](https://galaxy.ansible.com/)
  - [helm](https://helm.sh/)
    - Please use the version included with your Openshift Deployment
  - [pip3](https://pypi.org/project/pip/)

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

1. Setup Two [Github Oauth Apps](oauth-apps.md)

1. Generate a Personal Access Token for GitHub and set the `GITHUB_TOKEN` environment variable.
   See the official [Backstage Documentation](https://backstage.io/docs/getting-started/configuration#setting-up-a-github-integration) for information on how to create one.  

    !!! warning "Security Risk"
        Normally you would want to do this through your organization or a service account, but for the purposes of a demonstration, a Personal Access Token will do.

1. Create a [Github Organization](https://github.com/settings/organizations) and set the `GITHUB_ORGANIZATION` environment variable to the name of the Organization. You may also use any organization you are a member of, as long as you have the ability to create new repositories within it.
1. In order to create a webhook you'll need to Create a new GitHub Application.  You can do so by running the following command:

    **Linux**

    ```bash
    xdg-open "https://github.com/organizations/$GITHUB_ORGANIZATION/settings/apps/new?url=https://janus-idp.io/blog&webhook_active=false&public=false&administration=write&checks=write&actions=write&code=read&commit_statuses=write&dependabot_alerts=write&dependabot_secrets=write&deployments=write&discussions=write&environments=write&issues=write&packages=write&pages=write&pull_requests=write&reopository_hooks=write&repository_projects=write&secret_scanning_alerts=write&secrets=write&security_events=write&workflows=write&webhooks=write"
    ```

    **MacOS**

    ```bash
    open "https://github.com/organizations/$GITHUB_ORGANIZATION/settings/apps/new?url=https://janus-idp.io/blog&webhook_active=false&public=false&administration=write&checks=write&actions=write&code=read&commit_statuses=write&dependabot_alerts=write&dependabot_secrets=write&deployments=write&discussions=write&environments=write&issues=write&packages=write&pages=write&pull_requests=write&reopository_hooks=write&repository_projects=write&secret_scanning_alerts=write&secrets=write&security_events=write&workflows=write&webhooks=write"
    ```

    **Manually**

    Or by copying the following text and replacing `<ORGANIZATION>` with your organization name and pasting into your browser.

    ```bash
    https://github.com/organizations/<ORGANIZATION>/settings/apps/new?url=https://janus-idp.io/blog&webhook_active=false&public=false&administration=write&checks=write&actions=write&code=read&commit_statuses=write&dependabot_alerts=write&dependabot_secrets=write&deployments=write&discussions=write&environments=write&issues=write&packages=write&pages=write&pull_requests=write&reopository_hooks=write&repository_projects=write&secret_scanning_alerts=write&secrets=write&security_events=write&workflows=write&webhooks=write
    ```

## Installation

1. Clone the Assemble-Platform repository

    ``` sh
    git clone git@github.com:janus-idp/assemble-platforms.git
    ```

1. Run theAnsible Playbook Command:

    ```sh
    cd assemble-platforms/ansible/cluster-setup/
    ansible-playbook site.yaml -i inventory
    ```

    !!! tip
        Values in in `inventory/group_vars/all.yml` file can be modified if required
