# templates/_helpers.tpl
{{- define "b_log.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "b_log.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "b_log.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "b_log.labels" -}}
app.kubernetes.io/name: {{ include "b_log.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
{{- end -}}

{{- define "b_log.postgresql.host" -}}
{{ printf "%s-postgresql" .Release.Name }}
{{- end -}}

{{- define "b_log.nats.host" -}}
{{ printf "%s-nats" .Release.Name }}
{{- end -}}

{{- define "b_log.postgresql.conn" -}}
{{- $u := .Values.postgresql.auth.username -}}
{{- $p := .Values.postgresql.auth.password -}}
{{- $h := include "b_log.postgresql.host" . -}}
{{- $d := .Values.postgresql.auth.database -}}
{{ printf "%s:%s@%s:5432/%s" $u $p $h $d }}
{{- end -}}
