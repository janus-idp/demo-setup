# assemble-platforms
This repository contains automation to install the assemble platform including supporting components. 

## Helm Charts

The charts folder contains helm charts that can be used to setup supporting applications used by the assemble platform.  

### Installing components using helm

```bash
helm install $NAME -f my-values.yaml charts/$CHART_NAME
eg:
helm install my-gitops -f my-values.yaml charts/gitops-operator
```

### Chart README Files
For more info on each chart checkout these!
* [gitops-operator](/charts/gitops-operator)
* [pipelines-operator](/charts/pipelines-operator)
* [assemble-backstage](/charts/assemble-backstage)

## Backstage Github Apps


1. Follow the steps from the [Backstage Documentation](https://backstage.io/docs/integrations/github/github-apps)
2. The CLI command will set up everything but some permissions are missing. Make sure you have the following permissions to the GitHubApp created by the CLI:

* You need Read and Write access for:
    * Actions
    * Administration
    * Contents

* You need Read Only access for:
    * Metadata
    * Members
