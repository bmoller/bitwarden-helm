{{- define "bitwarden.persistentVolumeClaim" -}}
{{- $claim := first . -}}
{{- $component := index . 1 -}}
{{- $rootContext := last . -}}

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    {{- rest . | include "bitwarden.labels.selector" | nindent 4 }}
    app.kubernetes.io/name: {{ $claim.name }}
  name: bitwarden-{{ $component }}-{{ $claim.name }}
spec:
  accessModes:
    - {{ $claim.accessMode | quote }}
  resources:
    requests:
      storage: {{ $claim.size }}
  storageClassName: {{ $rootContext.Values.storageClassName | quote }}
{{- end -}}

{{- define "bitwarden.persistentVolumeClaim.size" -}}
{{- $volume := first . -}}
{{- $component :=  index . 1 -}}
{{- $rootContext := last . -}}

{{- $defaultValue := index $rootContext "Values" "volumeSize" $volume -}}
{{- if hasKey $rootContext.Values $component -}}
{{- $volumeKey := printf "%sVolumeSize" $volume -}}
{{- index $rootContext "Values" $component $volumeKey | default $defaultValue -}}
{{- else -}}
{{- $defaultValue -}}
{{- end -}}
{{- end -}}
