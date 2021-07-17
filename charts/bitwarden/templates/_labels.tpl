{{- define "bitwarden.labels.selector" -}}
{{- $component := first . -}}
{{- $rootContext := last . -}}

app.kubernetes.io/component: {{ $component | quote }}
app.kubernetes.io/instance: {{ $rootContext.Release.Name | quote }}
app.kubernetes.io/managed-by: {{ $rootContext.Release.Service | quote }}
app.kubernetes.io/part-of: bitwarden
{{- end -}}

{{- define "bitwarden.labels.service" -}}
{{- $component := first . -}}
{{- $rootContext := last . -}}

{{- include "bitwarden.labels.selector" . }}
app.kubernetes.io/version: {{ ternary $rootContext.Values.webVersion $rootContext.Values.version (eq $component "web") | quote }}
{{- end -}}
