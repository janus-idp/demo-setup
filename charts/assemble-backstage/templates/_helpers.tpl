{{/*
Expand the name of the chart.
*/}}
{{- define "assemble-backstage.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "assemble-backstage.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "assemble-backstage.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "assemble-backstage.labels" -}}
helm.sh/chart: {{ include "assemble-backstage.chart" . }}
{{ include "assemble-backstage.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "assemble-backstage.selectorLabels" -}}
app.kubernetes.io/name: {{ include "assemble-backstage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Postgresql Common labels
*/}}
{{- define "assemble-backstage.postgresql.labels" -}}
helm.sh/chart: {{ include "assemble-backstage.chart" . }}
{{ include "assemble-backstage.postgresql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.postgres.storage.labels }}
{{- tpl (toYaml .Values.postgres.storage.labels) $ }}
{{- end     }}
{{- end }}

{{/*
Postresql Selector labels
*/}}
{{- define "assemble-backstage.postgresql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "assemble-backstage.name" . }}-{{ .Values.postgres.database_name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "assemble-backstage.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "assemble-backstage.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check for existing secret
*/}}
{{- define "gen.postgres-password" -}}
{{- if .Values.postgres.database_password }}
databasePassword: {{ .Values.postgres.database_password | quote }}
{{- else -}}
{{/*
This will NOT work with ArgoCD, it currently does not support lookup functions
*/}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace  (printf "%s-%s" (include "assemble-backstage.fullname" . ) "postgresql") -}}
{{- if $secret -}}
{{/*
   Reusing existing secret data
databasePassword: {{ $secret.data.databasePassword | quote }}
*/}}
databasePassword: {{ $secret.data.databasePassword | b64dec | quote }}
{{- else -}}
{{/*
    Generate new data
*/}}
databasePassword: "{{ randAlphaNum 20 }}"
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the oauth proxy name
*/}}
{{- define "assemble-backstage.oauthProxy.name" -}}
{{- printf "%s-oauth-proxy" (include "assemble-backstage.fullname" . ) }}
{{- end }}

{{/*
Create the postgresql name
*/}}
{{- define "assemble-backstage.postgresql.name" -}}
{{- printf "%s-postgresql" (include "assemble-backstage.fullname" . ) }}
{{- end }}

{{/*
Create the rhsso issuerUrl
*/}}
{{- define "assemble-backstage.rhsso.issuerUrl" -}}
{{- printf "%s/realms/%s" .Values.rhsso.baseUrl .Values.rhsso.realm }}
{{- end }}
