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
    Define API URL for workspace or for
*/}}
{{- define "agent.apiUrl" -}}
{{- if eq .Values.agent.apiConfig "cloud" }}
{{- printf "%s/accounts/%s/workspaces/%s" .Values.agent.cloudApiConfig.cloudUrl .Values.agent.cloudApiConfig.accountId .Values.agent.cloudApiConfig.workspaceId | quote }}
{{- else }}
{{- .Values.agent.orionApiConfig.apiUrl | quote }}
{{- end }}
{{- end }}
