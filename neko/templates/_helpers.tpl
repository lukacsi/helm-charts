{{- define "neko.name" -}}
{{ .Chart.Name | default "neko" }}
{{- end }}

{{- define "neko.fullname" -}}
{{ .Release.Name }}-{{ include "neko.name" . }}
{{- end }}

{{- define "neko.labels" -}}
app: {{ include "neko.name" . }}
{{- end }}
