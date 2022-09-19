{{/*
Expand the name of the chart.
*/}}
{{- define "prefect-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prefect-agent.fullname" -}}
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
{{- define "prefect-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "prefect-agent.labels" -}}
helm.sh/chart: {{ include "prefect-agent.chart" . }}
{{ include "prefect-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- if .Values.config.commonLabels}}
{{ toYaml .Values.config.commonLabels }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prefect-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prefect-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prefect-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "prefect-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
  prefect-agent.apiUrl:
    Define API URL for workspace or for
*/}}
{{- define "prefect-agent.apiUrl" -}}
{{- if ne .Values.config.apiUrl  "https://api.prefect.cloud" }}
{{- .Values.config.apiUrl | quote }}
{{- else }}
{{- printf "%s/api/accounts/%s/workspaces/%s" .Values.config.apiUrl .Values.config.accountId .Values.config.workspaceName | quote }}
{{- end }}
{{- end }}
