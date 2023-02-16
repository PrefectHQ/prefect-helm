{{/*
Create the name of the service account to use
*/}}
{{- define "server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
  server.postgres-hostname:
    Generate the hostname of the postgresql service
    If a subchart is used, evaluate using its fullname function
      as {subchart.fullname}-{namespace}
    Otherwise, the configured external hostname will be returned
*/}}
{{- define "server.postgres-hostname" -}}
{{- if .Values.postgresql.useSubChart -}}
  {{- $subchart_overrides := .Values.postgresql -}}
  {{- $name := include "postgresql.primary.fullname" (dict "Values" $subchart_overrides "Chart" (dict "Name" "postgresql") "Release" .Release) -}}
  {{- printf "%s.%s" $name .Release.Namespace -}}
{{- else -}}
  {{- .Values.postgresql.externalHostname -}}
{{- end -}}
{{- end -}}

{{/*
  server.postgres-connstr:
    Generates the connection string for the postgresql service
*/}}
{{- define "server.postgres-connstr" -}}
{{- $user := .Values.postgresql.auth.username -}}
{{- $pass := .Values.postgresql.auth.password | required ".Values.postgresql.auth.password is required." -}}
{{- $host := include "server.postgres-hostname" . -}}
{{- $port := .Values.postgresql.containerPorts.postgresql | toString -}}
{{- $db := .Values.postgresql.auth.database -}}
{{- printf "postgresql+asyncpg://%s:%s@%s:%s/%s" $user $pass $host $port $db -}}
{{- end -}}

{{/*
  server.postgres-string-secret-name:
    Get the name of the secret to be used for the postgresql
    user password. Generates {release-name}-postgresql-connection if
    an existing secret is not set.
*/}}
{{- define "server.postgres-string-secret-name" -}}
{{- if .Values.postgresql.auth.existingSecret -}}
  {{- .Values.postgresql.auth.existingSecret -}}
{{- else -}}
  {{- $name := include "common.names.fullname" . -}}
  {{- printf "%s-%s" $name "postgresql-connection" -}}
{{- end -}}
{{- end -}}
