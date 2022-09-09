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

