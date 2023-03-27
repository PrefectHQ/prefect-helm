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
  worker.apiUrl:
    Define API URL for cloud or server worker install
*/}}
{{- define "worker.apiUrl" -}}
{{- if eq .Values.worker.apiConfig "cloud" }}
{{- printf "%s/accounts/%s/workspaces/%s" .Values.worker.cloudApiConfig.cloudUrl .Values.worker.cloudApiConfig.accountId .Values.worker.cloudApiConfig.workspaceId | quote }}
{{- else }}
{{- .Values.worker.serverApiConfig.apiUrl | quote }}
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
