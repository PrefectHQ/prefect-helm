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

// ----- Connection string templates ------

{{/*
  server.postgres-hostname:
    Generate the hostname of the postgresql service
    If a subchart is used, evaluate using its fullname function
		  and append the namespace at the end.
    Otherwise, the configured external hostname will be returned
*/}}
{{- define "server.postgres-hostname" -}}
{{- if .Values.postgresql.enabled -}}
{{-   $subchart_overrides := .Values.postgresql -}}
{{-   $name := include "postgresql.v1.primary.fullname" (dict "Values" $subchart_overrides "Chart" (dict "Name" "postgresql") "Release" .Release) -}}
{{-   printf "%s.%s" $name .Release.Namespace -}}
{{- else -}}
{{-   .Values.secret.host | required ".Values.secret.host is required." -}}
{{- end -}}
{{- end -}}

{{/*
  server.postgres-port:
    Generate the port of the postgresql service
    If a subchart is used, evaluate using its port function
    Otherwise, the configured port will be returned
*/}}
{{- define "server.postgres-port" -}}
{{- if .Values.postgresql.enabled -}}
{{-   $subchart_overrides := .Values.postgresql -}}
{{-   include "postgresql.v1.service.port" (dict "Values" $subchart_overrides) -}}
{{- else -}}
{{-   .Values.secret.port | required ".Values.secret.port is required." -}}
{{- end -}}
{{- end -}}

{{/*
  server.postgres-username:
    Generate the username for postgresql
    If a subchart is used, evaluate using its username function
    Otherwise, the configured username will be returned
*/}}
{{- define "server.postgres-username" -}}
{{- if .Values.postgresql.enabled -}}
{{-   $subchart_overrides := .Values.postgresql -}}
{{-   include "postgresql.v1.username" (dict "Values" $subchart_overrides) -}}
{{- else -}}
{{-   .Values.secret.username | required ".Values.secret.username is required." -}}
{{- end -}}
{{- end -}}

{{/*
  server.postgres-password:
    Generate the password for postgresql
    If a subchart is used, evaluate using its password value
    Otherwise, the configured password will be returned
*/}}
{{- define "server.postgres-password" -}}
{{- if .Values.postgresql.enabled -}}
{{-   .Values.postgresql.auth.password | required ".Values.postgresql.auth.password is required." -}}
{{- else -}}
{{-   .Values.secret.password | required ".Values.secret.password is required." -}}
{{- end -}}
{{- end -}}

{{/*
  server.postgres-database:
    Generate the database for postgresql
    If a subchart is used, evaluate using its database value
    Otherwise, the configured database will be returned
*/}}
{{- define "server.postgres-database" -}}
{{- if .Values.postgresql.enabled -}}
{{-   .Values.postgresql.auth.database | required ".Values.postgresql.auth.database is required." -}}
{{- else -}}
{{-   .Values.secret.database | required ".Values.secret.database is required." -}}
{{- end -}}
{{- end -}}

{{/*
  server.postgres-connstr:
    Generates the connection string for the postgresql service
*/}}
{{- define "server.postgres-connstr" -}}
{{- $user := include "server.postgres-username" . -}}
{{- $pass := include "server.postgres-password" . -}}
{{- $host := include "server.postgres-hostname" . -}}
{{- $port := include "server.postgres-port" . -}}
{{- $db := include "server.postgres-database" . -}}
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
{{- else if .Values.secret.name -}}
  {{- .Values.secret.name -}}
{{- else -}}
  {{- $name := include "common.names.fullname" . -}}
  {{- printf "%s-%s" $name "postgresql-connection" -}}
{{- end -}}
{{- end -}}

// ----- End connection string templates -----

{{- define "server.uiUrl" -}}
{{- if .Values.server.uiConfig.prefectUiUrl -}}
  {{- .Values.server.uiConfig.prefectUiUrl -}}
{{- else -}}
  {{- printf "%s" (replace "/api" "" .Values.server.prefectApiUrl) -}}
{{- end -}}
{{- end -}}
