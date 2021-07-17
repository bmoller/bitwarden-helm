{{- define "bitwarden.deployment" -}}
{{- $component := first . -}}
{{- $rootContext := last . -}}
{{- $localConfigServices := list "admin" "api" "events" "identity" "mssql" "notifications" "portal" "sso" -}}

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    {{- include "bitwarden.labels.service" . | nindent 4 }}
  name: bitwarden-{{ $component }}
spec:
  selector:
    matchLabels:
      {{- include "bitwarden.labels.selector" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "bitwarden.labels.service" . | nindent 8 }}
    spec:
      containers:
      - envFrom:
        {{- if ne $component "mssql" }}
        - configMapRef:
            name: bitwarden-defaults
        {{- end }}
        {{- if and (has $component $localConfigServices) (ne $component "mssql") }}
        - configMapRef:
            name: bitwarden-overrides
        - secretRef:
            name: bitwarden-config
        {{- end }}
        {{- if eq $component "mssql" }}
        - secretRef:
            name: bitwarden-mssql
        {{- end }}
        {{- if eq $component "mssql" }}
        env:
        - name: ACCEPT_EULA
          value: "Y"
        - name: MSSQL_PID
          value: Express
        {{- end }}
        image: bitwarden/{{ $component }}:{{ ternary $rootContext.Values.webVersion $rootContext.Values.version (eq $component "web") }}
        imagePullPolicy: IfNotPresent
        name: {{ $component | quote  }}
        ports:
        {{- if eq $component "mssql" }}
        - containerPort: 1433
          name: mssql
        {{- else if eq $component "nginx" }}
        - containerPort: 8080
          name: http
        {{- else }}
        - containerPort: 5000
          name: service
        {{- end }}
        resources:
          {{- include "bitwarden.deployment.resources" . | nindent 10 }}
        volumeMounts:
        {{- include "bitwarden.deployment.volumeMounts" . | indent 8 }}
      {{- if has $component $localConfigServices }}
      serviceAccountName: bitwarden-{{ $component }}
      {{- end }}
      {{- if eq $component "mssql" }}
      terminationGracePeriodSeconds: 60
      {{- end }}
      volumes:
      {{- include "bitwarden.deployment.volumes" . | indent 6 }}
{{- end -}}

{{- define "bitwarden.deployment.resources" -}}
{{- $component := first . -}}
{{- $rootContext := last . -}}

{{- $componentValues := false -}}
{{- if hasKey $rootContext.Values $component -}}
{{- $componentValues := index $rootContext "Values" $component "podResources" -}}
{{- end -}}

{{- if eq $component "mssql" -}}
{{ toYaml $rootContext.Values.mssql.podResources }}
{{- else if $componentValues -}}
{{ toYaml $componentValues }}
{{- else -}}
{{ toYaml $rootContext.Values.podResources }}
{{- end -}}
{{- end -}}

{{- define "bitwarden.deployment.volumeMounts" -}}
{{- $component := first . -}}
{{- $rootContext := last . -}}

{{- if eq $component "attachments" }}
- mountPath: /etc/bitwarden/core/attachments
  name: core
  subPath: attachments/
{{- end }}
{{- if eq $component "mssql" }}
- mountPath: /etc/bitwarden/mssql/backups
  name: backups
- mountPath: /var/opt/mssql/data
  name: data
- mountPath: /var/opt/mssql/log
  name: logs
{{- end }}
{{- if eq $component "nginx" }}
- mountPath: /etc/bitwarden/nginx
  name: config
- mountPath: /var/log/nginx
  name: logs
{{- end }}
{{- if eq $component "web" }}
- mountPath: /etc/bitwarden/web
  name: web
{{- end }}
{{- if has $component (list "identity" "sso") }}
- mountPath: /etc/bitwarden/identity
  name: identity
{{- end }}
{{- if has $component (list "admin" "api" "identity" "portal" "sso") }}
- mountPath: /etc/bitwarden/core
  name: core
{{- end }}
{{- if has $component (list "admin" "api" "events" "icons" "identity" "notifications" "portal" "sso") }}
- mountPath: /etc/bitwarden/ca-certificates
  name: ca-certificates
- mountPath: /etc/bitwarden/logs
  name: logs
{{- end }}
{{- end -}}

{{- define "bitwarden.deployment.volumes" -}}
{{- $component := first . -}}
{{- $rootContext := last . -}}

{{- if eq $component "mssql" }}
- name: backups
  persistentVolumeClaim:
    claimName: bitwarden-mssql-backups
- name: data
  persistentVolumeClaim:
    claimName: bitwarden-mssql-data
- name: logs
  persistentVolumeClaim:
    claimName: bitwarden-mssql-logs
{{- end }}
{{- if eq $component "nginx" }}
- configMap:
    name: bitwarden-nginx
  name: config
- name: logs
  persistentVolumeClaim:
    claimName: bitwarden-nginx-logs
{{- end }}
{{- if eq $component "web" }}
- configMap:
    name: bitwarden-web
  name: web
{{- end }}
{{- if has $component (list "identity" "sso") }}
- name: identity
  secret:
    secretName: {{ $rootContext.Values.identity.certificateSecret | quote }}
{{- end }}
{{- if has $component (list "admin" "api" "attachments" "identity" "portal" "sso") }}
- name: core
  persistentVolumeClaim:
    claimName: bitwarden-common-core
{{- end }}
{{- if has $component (list "admin" "api" "events" "icons" "identity" "notifications" "portal" "sso") }}
- name: ca-certificates
  persistentVolumeClaim:
    claimName: bitwarden-common-ca-certificates
- name: logs
  persistentVolumeClaim:
    claimName: bitwarden-{{ $component }}-logs
{{- end }}
{{- end -}}
