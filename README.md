# Assemble Platforms
This repository contains automation to install the assemble platform including supporting components. 

## Provisioning

The charts directory contains Helm charts that can be used to setup supporting applications used by the Assemble platform. These charts are referenced by ArgoCD applications and composed in a root application which is designed to install all platform dependencies.

### Provision the platform using ArgoCD

Provision the ArgoCD instance:

```bash
oc new-project assemble-argocd
helm install gitops-operator charts/gitops-operator
```

Apply the root application:

```bash
oc apply -f root-application.yaml
```

### Provision individual components using the Helm CLI

```bash
helm install $NAME -f my-values.yaml charts/$CHART_NAME
eg:
helm install my-gitops -f my-values.yaml charts/gitops-operator
```

### Chart README Files
For more info on each chart checkout these!
* [gitops-operator](/charts/gitops-operator)
* [pipelines-operator](/charts/pipelines-operator)
