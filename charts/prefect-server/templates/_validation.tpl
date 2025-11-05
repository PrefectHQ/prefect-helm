{{- define "prefect-server.validatePrefectVersion" -}}
{{- if and .Values.backgroundServices.runAsSeparateDeployment (eq .Values.global.prefect.image.repository "prefecthq/prefect") -}}
  {{- $prefectTag := .Values.global.prefect.image.prefectTag -}}
  {{- if not (regexMatch "^[0-9]+" $prefectTag) -}}
    {{- fail "When running background services separately, Prefect tag must start with a version number" -}}
  {{- end -}}

  {{- $version := regexFind "^[0-9]+\\.[0-9]+\\.[0-9]+" $prefectTag -}}
  {{- if not $version -}}
    {{- fail "When running background services separately, Prefect tag must be in format X.Y.Z" -}}
  {{- end -}}

  {{- $parts := splitList "." $version -}}
  {{- $major := index $parts 0 | atoi -}}
  {{- $minor := index $parts 1 | atoi -}}
  {{- $patch := index $parts 2 | atoi -}}

  {{- if or (lt $major 3) (and (eq $major 3) (lt $minor 1)) (and (eq $major 3) (eq $minor 1) (lt $patch 13)) -}}
    {{- fail "When running background services separately, Prefect version must be 3.1.13 or higher" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "prefect-server.validatePrefectServerApiSettings" -}}
{{- if .Values.global.prefect.prefectApiUrl -}}
  {{- fail "`global.prefect.prefectApiUrl` has been removed. Please use `server.uiConfig.prefectUiApiUrl` instead." -}}
{{- end -}}
{{- if .Values.global.prefect.prefectApiHost -}}
  {{- fail "`global.prefect.prefectApiHost` has been removed. Please use `server.uiConfig.prefectUiApiUrl` instead." -}}
{{- end -}}
{{- if .Values.server.uiConfig.prefectUiUrl -}}
  {{- fail "`server.uiConfig.prefectUiUrl` has been removed. This value was used solely for the purposes of printing out the UI URL during the installation process. It will now infer the UI URL from the `prefectUiApiUrl` value." -}}
{{- end -}}
{{- end -}}

{{- define "prefect-server.validateMessaging" -}}
{{- if and (.Values.backgroundServices.runAsSeparateDeployment) (and (not .Values.redis.enabled) (.Values.backgroundServices.messaging.redis.host | empty)) -}}
  {{- fail "You must set redis.enabled=true or provide a redis configuration when backgroundServices.runAsSeparateDeployment=true" -}}
{{- end -}}
{{- end -}}

{{- define "prefect-server.validateGatewayAPI" -}}
{{- if and .Values.gateway.enabled .Values.ingress.enabled -}}
  {{- fail "Gateway API and Ingress are mutually exclusive. Only one can be enabled at a time. Please set either gateway.enabled=false or ingress.enabled=false." -}}
{{- end -}}
{{- if and .Values.gateway.enabled (not .Values.gateway.className) -}}
  {{- fail "gateway.className is required when gateway.enabled=true. Please specify a GatewayClass that exists in your cluster." -}}
{{- end -}}
{{- if and .Values.gateway.enabled (not (include "gateway.apiAvailable" .)) -}}
  {{- fail "Gateway API (gateway.networking.k8s.io/v1) is not available in this cluster. Please install Gateway API CRDs or disable gateway.enabled." -}}
{{- end -}}
{{- end -}}
