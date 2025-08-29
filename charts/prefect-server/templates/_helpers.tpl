{{/*
Create the name of the service account to associate with the server deployment
*/}}
{{- define "server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to associate with the background-services deployment
*/}}
{{- define "backgroundServices.serviceAccountName" -}}
{{- if and .Values.backgroundServices.serviceAccount.create .Values.backgroundServices.runAsSeparateDeployment -}}
    {{ .Values.backgroundServices.serviceAccount.name | default (printf "%s-background-services" (include "common.names.fullname" .)) }}
{{- else -}}
    {{ default "default" .Values.backgroundServices.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- /*
    Reusable block for background services environment variables.
*/ -}}
{{- define "backgroundServices.envVars" -}}
{{- /*
Make redis subchart context available as a variable in this block
*/ -}}
{{- $redis := dict
      "Release"      .Release
      "Capabilities" .Capabilities
      "Values"       .Values.redis
      "Chart"        (dict "Name" "redis")
-}}
- name: PREFECT_API_DATABASE_MIGRATE_ON_START
  value: "false"
- name: PREFECT_MESSAGING_BROKER
  value: {{ .Values.backgroundServices.messaging.broker }}
- name: PREFECT_MESSAGING_CACHE
  value: {{ .Values.backgroundServices.messaging.cache }}
{{- if eq .Values.backgroundServices.messaging.broker "prefect_redis.messaging" }}
- name: PREFECT_SERVER_EVENTS_CAUSAL_ORDERING
  value: prefect_redis.ordering
- name: PREFECT_REDIS_MESSAGING_HOST
{{- if and (.Values.redis.enabled) (.Values.backgroundServices.messaging.redis.host | empty) }}
  value: {{ printf "%s-headless" (include "common.names.fullname" $redis) }}.{{ .Release.Namespace }}.svc.cluster.local
{{- else }}
  value: {{ .Values.backgroundServices.messaging.redis.host | quote }}
{{- end }}
- name: PREFECT_REDIS_MESSAGING_PORT
  value: {{ .Values.backgroundServices.messaging.redis.port | quote }}
{{- if (.Values.backgroundServices.messaging.redis.ssl) }}
- name: PREFECT_REDIS_MESSAGING_SSL
  value: {{ .Values.backgroundServices.messaging.redis.ssl | quote }}
{{- end }}
- name: PREFECT_REDIS_MESSAGING_DB
  value: {{ .Values.backgroundServices.messaging.redis.db | quote }}
{{- if not (.Values.backgroundServices.messaging.redis.username | empty) }}
- name: PREFECT_REDIS_MESSAGING_USERNAME
  value: {{ .Values.backgroundServices.messaging.redis.username | quote }}
{{- end -}}
{{- /*
There are three scenarios for passwords:
    1. If the subchart is enabled, reference the secret from the subchart.
       Setting backgroundServices.messaging.redis.password has no effect here.
    2. If the subchart is not enabled, use the secret defined in the values file. TODO: secret reference
    3. No password is set, so the environment variable is not defined.
*/ -}}
{{- if and (.Values.redis.enabled) (.Values.backgroundServices.messaging.redis.password | empty) }}
- name: PREFECT_REDIS_MESSAGING_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "common.names.fullname" $redis }}
      key: redis-password
{{- else if not (.Values.backgroundServices.messaging.redis.password | empty) }}
- name: PREFECT_REDIS_MESSAGING_PASSWORD
  value: {{ .Values.backgroundServices.messaging.redis.password | quote }}
{{- end }}
{{- end }}
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
  {{- printf "%s" (replace "/api" "" .Values.server.uiConfig.prefectUiApiUrl) -}}
{{- end -}}
