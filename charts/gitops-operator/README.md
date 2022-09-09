# ⚓️ GitOps Operator Helm Deploy

The GitOps  Helm Chart customizes and deploys the [RedHat GitOps Operator](https://github.com/redhat-developer/gitops-operator) written by Red Hat.

## Installing the chart

To install the chart from source:
```bash
# within this directory 
oc new-project assemble-argocd
helm upgrade --install argocd . -f values.yaml 
```

## Configuration

The [values.yml](values.yaml) file contains instructions for common chart overrides.

You can install multiple team instances of ArgoCD into different namespaces, just add your namespace to this list. Namespaces will be created first e.g. shown above for a single namespace called `assemble-gitops`.

RBAC for each ArgoCD instance is `cluster-admin` scoped by default. You can create `namespaced` ArgoCD instances by specifying `teamInstancesAreClusterScoped: false`. This setting does not deploy any excess RBAC and uses the defaults from the gitops-operator.

If you want fine-grained access, you may set `clusterRoleRulesController` and `clusterRoleRulesServer` with Role rules that suit your purpose.

The default GitOps ArgoCD instance is _not_ deployed in the `openshift-gitops` operator project. You can enable it by setting `disableDefaultArgoCD: false`

You _do not_ need to override the ArgoCD `applicationInstanceLabelKey`. It is automatically generated based on the namespace name.

Anything configurable in the Operator is passed to the ArgoCD custom resource provided by the Operator. See `argocd_cr` in `values.yaml` for example defaults. For more detailed overview of what's included, checkout the [ArgoCD Operator Docs](https://argocd-operator.readthedocs.io/en/latest/reference/argocd/).

If you wish to use ArgoCD to manage this chart directly (or as a helm chart dependency) you may need to make use of the `ignoreHelmHooks` flag to ignore helm lifecycle hooks.

One example might be deploying team instances without the Operator and helm lifecycle hooks.
```bash
helm instance argocd ./charts/gitops-operator --set operator=null --set ignoreHelmHooks=true 
```

## Removing

To delete the chart:
```bash
helm uninstall argocd --namespace assemble-gitops
oc delete project assemble-argocd

### If ignoreHelmHooks is set to 'false' you will need to remove the argocd and appproject resources manually
oc delete argocd argocd
oc delete appproject default
```

