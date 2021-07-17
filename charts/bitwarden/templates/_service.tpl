{{- define "bitwarden.service" -}}
{{- $component := first . -}}
{{- $rootContext := last . -}}

apiVersion: v1
kind: Service
metadata:
  labels:
    {{- include "bitwarden.labels.service" . | nindent 4 }}
  name: bitwarden-{{ $component }}
spec:
  ports:
  - port: {{ ternary 1433 5000 (eq $component "mssql") }}
    targetPort: {{ ternary "mssql" "service" (eq $component "mssql") }}
  selector:
    {{- include "bitwarden.labels.selector" . | nindent 4 }}
{{- end -}}
