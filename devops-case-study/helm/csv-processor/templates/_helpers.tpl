{{- define "csv-processor.name" -}}
csv-processor
{{- end -}}

{{- define "csv-processor.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "csv-processor.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "csv-processor.labels" -}}
app.kubernetes.io/name: {{ include "csv-processor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

{{- define "csv-processor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "csv-processor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "csv-processor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "csv-processor.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
default
{{- end -}}
{{- end -}}
