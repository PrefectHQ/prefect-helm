{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "prometheus-prefect-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "prometheus-prefect-exporter.labels" -}}
helm.sh/chart: {{ include "prometheus-prefect-exporter.chart" . }}
{{ include "prometheus-prefect-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheus-prefect-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-prefect-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
