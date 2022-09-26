{{/*
Expand the name of the chart.
*/}}
{{- define "rhsso-cluster-auth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rhsso-cluster-auth.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rhsso-cluster-auth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rhsso-cluster-auth.labels" -}}
helm.sh/chart: {{ include "rhsso-cluster-auth.chart" . }}
{{ include "rhsso-cluster-auth.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rhsso-cluster-auth.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rhsso-cluster-auth.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "rhsso-cluster-auth.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rhsso-cluster-auth.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rhsso-cluster-auth.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the Redirect URI for OpenShift Authentication 
*/}}
{{- define "rhsso-cluster-auth.redirecturi" -}}
{{- printf "https://oauth-openshift.apps.%s" (required "Base domain must be provided" .Values.openshift.base_domain) }}/oauth2callback/{{ .Values.openshift.idp.name }}
{{- end }}

{{/*
Create the Redirect URI for OpenShift Authentication 
*/}}
{{- define "rhsso-cluster-auth.clientSecretName" -}}
{{ printf "keycloak-client-secret-%s" .Values.keycloak.client.name }}
{{- end }}