{{/*
Expand the name of the chart.
*/}}
{{- define "rhsso-backstage.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rhsso-backstage.fullname" -}}
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
{{- define "rhsso-backstage.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rhsso-backstage.labels" -}}
helm.sh/chart: {{ include "rhsso-backstage.chart" . }}
{{ include "rhsso-backstage.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rhsso-backstage.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rhsso-backstage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "rhsso-backstage.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rhsso-backstage.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rhsso-backstage.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the Redirect URI for OpenShift Authentication 
*/}}
{{- define "rhsso-backstage.clientSecretName" -}}
{{ printf "keycloak-client-secret-%s" .Values.keycloak.client.name }}
{{- end }}
