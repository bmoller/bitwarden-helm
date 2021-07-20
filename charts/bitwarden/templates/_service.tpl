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
  - name: {{ get (dict "mssql" "mssql" "nginx" "http") $component | default "service" }}
    port: {{ get (dict "mssql" 1433 "nginx" 80) $component | default 5000 }}
    targetPort: {{ get (dict "mssql" "mssql" "nginx" "http") $component | default "service" }}
  selector:
    {{- include "bitwarden.labels.selector" . | nindent 4 }}
{{- end -}}
