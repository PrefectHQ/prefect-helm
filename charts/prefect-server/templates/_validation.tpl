{{- define "prefect-server.validatePrefectVersion" -}}
{{- if .Values.backgroundServices.runAsSeparateDeployment -}}
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