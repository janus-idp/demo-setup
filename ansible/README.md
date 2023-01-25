# Installing Assemble with Ansible
This guide walks you though how to install Assemble with Ansible

## Prereqs
1. Ensure `ansible`, `helm`, and `pip3` are installed.

2. The Ansible `kubernetes.core` and `community.general` collections needs to be installed before using this playbook.
 ```
 ansible-galaxy collection install kubernetes.core
 ansible-galaxy collection install community.general
```

3. The `kubernetes`, `openshift`, and `PyYAML` python packages need to be installed before using this playbook.
 ```
 pip3 install --user kubernetes openshift PyYAML
 ```

4. The `helm diff` plugin needs to be installed before using this playbook.
 ```
helm plugin install https://github.com/databus23/helm-diff
 ```
5. Login to OpenShift
6. If you want to use the GitHub integration, generate a Personal Access Token for GitHub and set the `GITHUB_TOKEN` environment variable.
   See the official [Backstage Documentation](https://backstage.io/docs/getting-started/configuration#setting-up-a-github-integration) for information on how to create one.  For the purposes of a demonstration, a Personal Access Token will do.
7. If you want to use GitHub as an IDP for backstage then create an GitHub app and set the `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` environment variables.
  Create a [GitHub OAuth Application](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) within the desired organization.  Use the following commands to generate the sample values used for this demo.

  Homepage URL:

  ```
  echo "https://assemble-demo.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')"
  ```

  Authorization callback URL:

  ```
  echo "https://keycloak-backstage.apps$(oc cluster-info | grep -Eo '.cluster(.*?).com')/auth/realms/backstage/broker/github/endpoint"
  ```
8. Create a Github Organization and set the `GITHUB_ORGANIZATION` environment variable to the name of the Organization.  You may also use any organization you are a member of, as long as you have the ability to create new repositories within it.

## Create the enviroment

** Install helm charts
```
ansible-playbook site.yaml -i inventory
```