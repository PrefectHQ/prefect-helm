{{/*
Create the name of the service account to use
*/}}
{{- define "agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
  agent.apiUrl:
    Define API URL for cloud or server agent install
*/}}
{{- define "agent.apiUrl" -}}
{{- if eq .Values.agent.apiConfig "cloud" }}
{{- printf "%s/accounts/%s/workspaces/%s" .Values.agent.cloudApiConfig.cloudUrl .Values.agent.cloudApiConfig.accountId .Values.agent.cloudApiConfig.workspaceId | quote }}
{{- else }}
{{- .Values.agent.serverApiConfig.apiUrl | quote }}
{{- end }}
{{- end }}

{{/*
  agent.clusterUUID:
    Define cluster UID either from user-defined UID or by doing a lookup at helm install time
*/}}
{{- define "agent.clusterUUID" -}}
{{- $defaultDict := dict "metadata" (dict "uid" "") -}}
{{- if .Values.agent.clusterUid }}
{{- .Values.agent.clusterUid | quote }}
{{- else }}
{{- (lookup "v1" "Namespace" "" "kube-system" | default $defaultDict).metadata.uid | quote }}
{{- end }}
{{- end }}
