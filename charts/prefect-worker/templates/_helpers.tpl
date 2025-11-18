{{/*
Create the name of the service account to use
*/}}
{{- define "worker.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Require Prefect Cloud Account ID
*/}}
{{- define "cloud.requiredConfig.accountId" -}}
{{- if eq .Values.worker.apiConfig "cloud" }}
    {{- required "A Prefect Cloud Account ID is required (worker.cloudApiConfig.accountId)" .Values.worker.cloudApiConfig.accountId -}}
{{- end -}}
{{- end -}}

{{/*
Require Prefect Cloud Workspace ID
*/}}
{{- define "cloud.requiredConfig.workspaceId" -}}
{{- if eq .Values.worker.apiConfig "cloud" }}
    {{- required "A Prefect Cloud Workspace ID is required (worker.cloudApiConfig.workspaceId)" .Values.worker.cloudApiConfig.workspaceId -}}
{{- end -}}
{{- end -}}

{{/*
Require Self-managed Cloud Account ID
*/}}
{{- define "selfManaged.requiredConfig.accountId" -}}
{{- if eq .Values.worker.apiConfig "customerManagedCloud" }}
    {{- required "A Prefect Cloud Account ID is required (worker.customerManagedCloudApiConfig.accountId)" .Values.worker.customerManagedCloudApiConfig.accountId -}}
{{- end -}}
{{- end -}}

{{/*
Require Self-managed Cloud Workspace ID
*/}}
{{- define "selfManaged.requiredConfig.workspaceId" -}}
{{- if eq .Values.worker.apiConfig "customerManagedCloud" }}
    {{- required "A Prefect Cloud Workspace ID is required (worker.customerManagedCloudApiConfig.workspaceId)" .Values.worker.customerManagedCloudApiConfig.workspaceId -}}
{{- end -}}
{{- end -}}

{{/*
Require Self-managed Cloud API URL
*/}}
{{- define "selfManaged.requiredConfig.apiUrl" -}}
{{- if eq .Values.worker.apiConfig "customerManagedCloud" }}
    {{- required "The Self-managed Cloud API URL is required (worker.customerManagedCloudApiConfig.apiUrl)" .Values.worker.customerManagedCloudApiConfig.apiUrl -}}
{{- end -}}
{{- end -}}

{{/*
Require Prefect Server API URL
*/}}
{{- define "server.requiredConfig.apiUrl" -}}
{{- if eq .Values.worker.apiConfig "selfHostedServer" }}
    {{- required "The Prefect Server API URL is required (worker.selfHostedServerApiConfig.apiUrl)" .Values.worker.selfHostedServerApiConfig.apiUrl -}}
{{- end -}}
{{- end -}}

{{/*
  worker.apiUrl:
    Define the API URL for the worker based on the API config
*/}}
{{- define "worker.apiUrl" -}}
{{- if eq .Values.worker.apiConfig "cloud" }}
    {{- printf "%s/accounts/%s/workspaces/%s" .Values.worker.cloudApiConfig.cloudUrl (include "cloud.requiredConfig.accountId" .) (include "cloud.requiredConfig.workspaceId" .) | quote }}
{{- else if eq .Values.worker.apiConfig "customerManagedCloud" }}
    {{- printf "%s/accounts/%s/workspaces/%s" (include "selfManaged.requiredConfig.apiUrl" .) (include "selfManaged.requiredConfig.accountId" .) (include "selfManaged.requiredConfig.workspaceId" .) | quote }}
{{- else if eq .Values.worker.apiConfig "selfHostedServer" }}
    {{- include "server.requiredConfig.apiUrl" . | quote }}
{{- end }}
{{- end }}


{{/*
  worker.clusterUUID:
    Define cluster UID either from user-defined UID or by doing a lookup at helm install time
*/}}
{{- define "worker.clusterUUID" -}}
{{- $defaultDict := dict "metadata" (dict "uid" "") -}}
{{- if .Values.worker.clusterUid }}
    {{- .Values.worker.clusterUid | quote }}
{{- else }}
    {{- (lookup "v1" "Namespace" "" "kube-system" | default $defaultDict).metadata.uid | quote }}
{{- end }}
{{- end }}

{{/*
Determine the name of the ConfigMap for the baseJobTemplate
*/}}
{{- define "worker.baseJobTemplateName" -}}
{{- if .Values.worker.config.baseJobTemplate.configuration -}}
    {{ default "prefect-worker-base-job-template" .Values.worker.config.baseJobTemplate.name . }}
{{- else if .Values.worker.config.baseJobTemplate.existingConfigMapName -}}
    {{ .Values.worker.config.baseJobTemplate.existingConfigMapName }}
{{- else -}}
{{- end -}}
{{- end -}}
