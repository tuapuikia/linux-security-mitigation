{{/*
Expand the name of the chart.
*/}}
{{- define "kernel-lpe-mitigator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "kernel-lpe-mitigator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kernel-lpe-mitigator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kernel-lpe-mitigator.labels" -}}
helm.sh/chart: {{ include "kernel-lpe-mitigator.chart" . }}
{{ include "kernel-lpe-mitigator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
purpose: security-mitigation
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kernel-lpe-mitigator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kernel-lpe-mitigator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: kernel-lpe-mitigate
{{- end }}
