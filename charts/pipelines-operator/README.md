# ⚓️ Openshift Pipelines Operator Helm Deploy

The Openshift Pipelines Helm Chart customizes and deploys the [RedHat Openshift Pipelines Operator](https://docs.openshift.com/container-platform/4.10/cicd/pipelines/installing-pipelines.html) written by Red Hat.

## Installing the chart

To install the chart from source:
```bash
# within this directory 
helm upgrade --install pipelines . -f values.yaml -n janus-pipelines --create-namespace
```
To install using oc apply
```bash
# within this directory
helm template pipelines --set ignoreHelmHooks=true . | oc apply -f- 
```

## Configuration

The [values.yml](values.yaml) file contains instructions for common chart overrides.

The operator version can be configuring by modifying the operator configuration values. The startingCSV could be different based on the openshift cluster version.  The channel can be latest, stable or a specific version.

```yaml
# operator manages upgrades
operator:
  channel: latest
  installPlanApproval: Automatic
  name: openshift-pipelines-operator-rh
  sourceName: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: openshift-pipelines-operator-rh.v1.8.0
```


## Removing

To delete the chart:
```bash
helm uninstall pipelines --namespace janus-pipelines
```

To delete when not using helm
```
helm template pipelines --set ignoreHelmHooks=true . | oc delete -f-
oc delete csv openshift-pipelines-operator-rh.v1.8.0 -n openshift-operators
```

