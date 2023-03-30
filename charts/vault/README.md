# ⚓️ Hashicorp Vault Helm Deploy

The Vault Helm Chart extends the Hashicorp [Vault Helm Chart](https://github.com/hashicorp/vault-helm) owned by Hashicorp. This will install the Vault with extra containers to unseal the vault and create the root access token to begin using the vault. 

## Installing the chart

The `values.yaml` file in the folder charts/vault folder needs to be modified for each environment. The default values file will not include plugins for external tools like Quay and Github but those plugins can be included by adding to the values file.  To install the basic vault service do the following:

1) Make a copy of the charts/vault/values.yaml 
```bash
cp charts/vault/values.yaml my-values.yaml
```
2) Update the namespace place holder with the target namespace, i.e 'janus'.
```bash
sed -i 's/<namespace_replace>/janus/g' ./my-values.yaml
```
3) Create or verify using target project
```
oc new-project janus
```

4) Install via Helm
```bach
helm upgrade -n janus -u vault --set base_domain=$(oc get dns cluster -o jsonpath='{ .spec.baseDomain }' --values ./my-values.yaml ./charts/vault
```

## Post installation verification

NOTE: There is a known intermittent [issue](https://github.com/hashicorp/vault-helm/issues/674) with the helm install of vault where the generated certificate is not valid for the vault service after initial install. Execute the following command to determine if the issue did occur as part of the installation:

```bash
oc get svc vault -o jsonpath='{ .metadata.annotations.service\.alpha\.openshift\.io/serving-cert-generation-error }'
```

If a value was returned, perform the following actions:


1) Scale the vault StatefulSet to zero.

```bash
oc scale --replicas=0 statefulset/vault
```

2) Remove the annotations from the vault-internal service

```bash
kubectl patch svc vault-internal --type='json' -p '[{"op": "remove", "path": "/metadata/annotations/service.beta.openshift.io~1serving-cert-secret-name"}]'
kubectl patch svc vault-internal --type='json' -p '[{"op": "remove", "path": "/metadata/annotations/service.alpha.openshift.io~1serving-cert-signed-by"}]'
kubectl patch svc vault-internal --type='json' -p '[{"op": "remove", "path": "/metadata/annotations/service.beta.openshift.io~1serving-cert-signed-by"}]'
```

3) Remove the annotations from the the vault service

```bash
kubectl patch svc vault --type='json' -p '[{"op": "remove", "path": "/metadata/annotations/service.alpha.openshift.io~1serving-cert-generation-error"}]'
kubectl patch svc vault --type='json' -p '[{"op": "remove", "path": "/metadata/annotations/service.beta.openshift.io~1serving-cert-generation-error"}]'
kubectl patch svc vault --type='json' -p '[{"op": "remove", "path": "/metadata/annotations/service.alpha.openshift.io~1serving-cert-generation-error-num"}]'
kubectl patch svc vault --type='json' -p '[{"op": "remove", "path": "/metadata/annotations/service.beta.openshift.io~1serving-cert-generation-error-num"}]'
```

4) Delete the vault-server-tls generated secret and scale the statefullset back to 1

```bash
oc delete secret vault-server-tls
oc scale --replicas=1 statefulset/vault
```

It may take up to 10 minutes for the 'vault-server-tls' secret to get re-created. Once that is done the vault pod should start up successfully.

## Configuration

The [values.yml](values.yaml) contains examples of additional plugins for the vault to generate secrets for services like quay and github. To enable the plugins remove the comments '#" in front of the extraInitContainers and extraContainers sections and update appropriate values. 

## Removing

To delete the chart:
```bash
helm uninstall vault -n janus
```
