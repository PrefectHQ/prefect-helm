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
{{- if eq .Values.worker.apiConfig "selfManaged" }}
    {{- required "A Prefect Cloud Account ID is required (worker.selfManagedCloudApiConfig.accountId)" .Values.worker.selfManagedCloudApiConfig.accountId -}}
{{- end -}}
{{- end -}}

{{/*
Require Self-managed Cloud Workspace ID
*/}}
{{- define "selfManaged.requiredConfig.workspaceId" -}}
{{- if eq .Values.worker.apiConfig "selfManaged" }}
    {{- required "A Prefect Cloud Workspace ID is required (worker.selfManagedCloudApiConfig.workspaceId)" .Values.worker.selfManagedCloudApiConfig.workspaceId -}}
{{- end -}}
{{- end -}}

{{/*
Require Self-managed Cloud API URL
*/}}
{{- define "selfManaged.requiredConfig.apiUrl" -}}
{{- if eq .Values.worker.apiConfig "selfManaged" }}
    {{- required "The Self-managed Cloud API URL is required (worker.selfManagedCloudApiConfig.apiUrl)" .Values.worker.selfManagedCloudApiConfig.apiUrl -}}
{{- end -}}
{{- end -}}

{{/*
Require Prefect Server API URL
*/}}
{{- define "server.requiredConfig.apiUrl" -}}
{{- if eq .Values.worker.apiConfig "server" }}
    {{- required "The Prefect Server API URL is required (worker.serverApiConfig.apiUrl)" .Values.worker.serverApiConfig.apiUrl -}}
{{- end -}}
{{- end -}}

{{/*
  worker.apiUrl:
    Define API URL for cloud or server worker install
*/}}
{{- define "worker.apiUrl" -}}
{{- if eq .Values.worker.apiConfig "cloud" }}
    {{- printf "%s/accounts/%s/workspaces/%s" .Values.worker.cloudApiConfig.cloudUrl (include "cloud.requiredConfig.accountId" .) (include "cloud.requiredConfig.workspaceId" .) | quote }}
{{- else if eq .Values.worker.apiConfig "selfManaged" }}
    {{- printf "%s/accounts/%s/workspaces/%s" (include "selfManaged.requiredConfig.apiUrl" .) (include "selfManaged.requiredConfig.accountId" .) (include "selfManaged.requiredConfig.workspaceId" .) | quote }}
{{- else }}
    {{- include "server.requiredConfig.apiUrl" . | quote }}
{{- end }}
{{- end }}

{{/*
  worker.appUrl:
    Define APP URL for cloud worker install
*/}}
{{- define "worker.appUrl" -}}
{{- if eq .Values.worker.apiConfig "cloud" }}
    {{- printf "https://app.prefect.cloud/account/%s/workspace/%s" (include "cloud.requiredConfig.accountId" .) (include "cloud.requiredConfig.workspaceId" .) | quote }}
{{- else if eq .Values.worker.apiConfig "selfManaged" }}
    {{- printf "%s/account/%s/workspace/%s" .Values.worker.selfManagedCloudApiConfig.uiUrl (include "selfManaged.requiredConfig.accountId" .) (include "selfManaged.requiredConfig.workspaceId" .) | quote }}
{{- else }}
    {{- .Values.worker.serverApiConfig.uiUrl | quote }}
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
