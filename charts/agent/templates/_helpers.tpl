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
{{- if ne .Values.agent.config.apiUrl  "https://api.prefect.cloud" }}
{{- .Values.agent.config.apiUrl | quote }}
{{- else }}
{{- printf "%s/api/accounts/%s/workspaces/%s" .Values.agent.config.apiUrl .Values.agent.config.accountId .Values.agent.config.workspaceName | quote }}
{{- end }}
{{- end }}
