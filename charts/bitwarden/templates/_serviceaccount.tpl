{{- define "bitwarden.serviceAccount" -}}
{{- $component := first . -}}
{{- $rootContext := last . -}}

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    {{- include "bitwarden.labels.selector" . | nindent 4 }}
  name: bitwarden-{{ $component }}
secrets:
{{- if eq $component "mssql" }}
- name: bitwarden-mssql
{{- else }}
- name: bitwarden-config
{{- end }}
{{- if has $component (list "identity" "sso") }}
- name: {{ $rootContext.Values.identity.certificateSecret | quote }}
{{- end }}
{{- end -}}
