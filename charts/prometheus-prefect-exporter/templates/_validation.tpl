{{/*
Fail on values that a single-replica exporter no longer supports. Each extra
exporter pod counts every flow run again.
*/}}
{{- define "prometheus-prefect-exporter.validateSingleReplica" -}}
{{- if and (hasKey .Values "replicaCount") (not (kindIs "invalid" .Values.replicaCount)) (ne (int .Values.replicaCount) 1) -}}
  {{- fail "replicaCount is no longer supported: the exporter counts flow runs from the event stream and must run as exactly one replica. Remove replicaCount, or set it to 1." -}}
{{- end -}}
{{- if (.Values.autoscaling | default dict).enabled -}}
  {{- fail "autoscaling is no longer supported: the exporter must run as exactly one replica. Remove autoscaling." -}}
{{- end -}}
{{- if .Values.podDisruptionBudget -}}
  {{- fail "podDisruptionBudget is no longer supported: the exporter runs as one replica, replaced with Recreate. Remove podDisruptionBudget." -}}
{{- end -}}
{{- end -}}
