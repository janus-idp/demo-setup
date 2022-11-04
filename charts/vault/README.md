# ⚓️ Hashicorp Vault Helm Deploy

The Vault Helm Chart extends the Hashicorp [Vault Helm Chart](https://github.com/hashicorp/vault-helm) owned by Hashicorp. This will install the Vault with extra containers to unseal the vault and create the root access token to begin using the vault. 

## Installing the chart

The values.yaml file in the folder charts/vault folder needs to be modified for each environment. The default values file will not include plugins for external tools like Quay and Github but those plugins can be included by adding to the values file.  To install the basic vault service do the following:

1) Make a copy of the charts/vault/values.yaml 
```bash
cp charts/vault/values.yaml my-values.yaml
```
2) Update the namespace place holder with the target namespace, i.e 'assemble'.
```bash
sed -i 's/<namespace_replace>/assemble/g' ./my-values.yaml
```
3) Create or verify using target project
```
oc new-project assemble
```

4) Get your base domain for the cluster.
```
mydomain=$(oc get routes --all-namespaces | grep -i console-openshift | awk '{ print $3 }')
echo ${mydomain:31}
```

5) Install via Helm
```bach
helm install vault --set base_domain="example.com" --values ./my-values.yaml ./charts/vault
```

## Post installation verification

NOTE: There is a known intermittent [issue](https://github.com/hashicorp/vault-helm/issues/674) with the helm install of vault where the generated certificate is not valid for the vault service after initial install. Check the logs for the vault pod auto-inialize containers for errors.

```bash
oc logs vault-0 -c auto-initializer
``

If you see an error like '... vault-internal.assemble.svc.cluster.local, not vault.assemble.svc.' perform the following steps to fix.

1) Scale the vault statefullset to zero.

```bash
oc scale --replicas=0 statefulset/vault
```
2) Edit the vault-internal service

```bash
oc edit svc vault-internal

## Remove the three annotations similary to the following
# 11     service.alpha.openshift.io/serving-cert-signed-by: openshift-service-serving-signer@1667207204
# 12     service.beta.openshift.io/serving-cert-secret-name: vault-server-tls
# 13     service.beta.openshift.io/serving-cert-signed-by: openshift-service-serving-signer@1667207204
```

3) Edit the vault service

```bash
oc edit svc vault

## Remove the four annotations similar to the ones below
#11     service.alpha.openshift.io/serving-cert-generation-error: secret assemble-dev/vault-server-tls
#12       does not have corresponding service UID 36678892-121f-4693-94a4-173a41a6b8c4
#13     service.alpha.openshift.io/serving-cert-generation-error-num: "10"
#14     service.beta.openshift.io/serving-cert-generation-error: secret assemble-dev/vault-server-tls
#15       does not have corresponding service UID 36678892-121f-4693-94a4-173a41a6b8c4
#16     service.beta.openshift.io/serving-cert-generation-error-num: "10"

4) Delete the vault-server-tls generated secret and scale the statefullset back to 1

```bash
oc delete secret vault-server-tls
oc scale --replicas=1 statefulset/vault
```

It will take up to 10 minutes for the 'vault-server-tls' secret to get re-created. Once that is done the vault pod should start up successfully.

## Configuration

The [values.yml](values.yaml) contains examples of additional plugins for the vault to generate secrets for services like quay and github. To enable the plugins remove the comments '#" in front of the extraInitContainers and extraContainers sections and update appropriate values. 

## Removing

To delete the chart:
```bash
helm uninstall vault --namespace assemble
```
