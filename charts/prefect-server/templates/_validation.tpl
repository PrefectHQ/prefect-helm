{{- define "prefect-server.validatePrefectVersion" -}}
{{- if .Values.backgroundServices.runAsSeparateDeployment }}
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
  {{- fail "prefectApiUrl is deprecated. Please use `.Values.server.uiConfig.prefectUiApiUrl` instead." -}}
{{- end -}}
{{- if .Values.global.prefect.prefectApiHost -}}
  {{- fail "`global.prefect.prefectApiHost` has been removed. Please use `server.uiConfig.prefectUiApiUrl` instead." -}}
{{- end -}}
{{- if .Values.server.uiConfig.prefectUiUrl -}}
  {{- fail "`server.uiConfig.prefectUiUrl` has been removed. This value was used solely for the purposes of printing out the UI URL during the installation process. It will now infer the UI URL from the `prefectUiApiUrl` value." -}}
{{- end -}}
{{- end -}}