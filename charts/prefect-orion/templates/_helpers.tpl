

{{/*
  env-unrap:
    Converts a nested dictionary with keys `prefix` and `map`
    into a list of environment variable definitions, where each
    variable name is an uppercased concatenation of keys in the map
    starting with the original prefix and descending to each leaf.
    The variable value is then the quoted value of each leaf key.
*/}}
{{- define "env-unwrap" -}}
{{- $prefix := .prefix -}}
{{/* Iterate through all keys in the current map level */}}
{{- range $key, $val := .map -}}
{{- $key := upper $key -}}
{{/* Create an environment variable if this is a leaf */}}
{{- if ne (typeOf $val | toString) "map[string]interface {}" }}
- name: {{ printf "%s_%s" $prefix $key }}
  value: {{ $val | quote }}
{{/* Otherwise, recurse into each child key with an updated prefix */}}
{{- else -}}
{{- $prefix := (printf "%s__%s" $prefix $key) -}}
{{- $args := (dict "prefix" $prefix "map" $val)  -}}
{{- include "env-unwrap" $args -}}
{{- end -}}
{{- end -}}
{{- end -}}
