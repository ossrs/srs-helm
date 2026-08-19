{{/*
Expand the name of the chart.
*/}}
{{- define "oryx-origin-cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "oryx-origin-cluster.fullname" -}}
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
oryx pod name
*/}}
{{- define "oryx-origin-cluster.oryx-name" -}}
{{- printf "%s-%s" .Release.Name "oryx" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
redis pod name
*/}}
{{- define "oryx-origin-cluster.redis-name" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
srs pod name
*/}}
{{- define "oryx-origin-cluster.srs-name" -}}
{{- printf "%s-%s" .Release.Name "srs" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
srs-proxy pod name
*/}}
{{- define "oryx-origin-cluster.srs-proxy-name" -}}
{{- printf "%s-%s" .Release.Name "srs-proxy" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "oryx-origin-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "oryx-origin-cluster.labels" -}}
helm.sh/chart: {{ include "oryx-origin-cluster.chart" . }}
{{ include "oryx-origin-cluster.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "oryx-origin-cluster.selectorLabels" -}}
app.kubernetes.io/name: {{ include "oryx-origin-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
oryx labels
*/}}
{{- define "oryx-origin-cluster.oryxLabels" -}}
helm.sh/chart: {{ include "oryx-origin-cluster.chart" . }}
{{ include "oryx-origin-cluster.oryxSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector oryx labels
*/}}
{{- define "oryx-origin-cluster.oryxSelectorLabels" -}}
app.kubernetes.io/name: {{ include "oryx-origin-cluster.oryx-name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
redis labels
*/}}
{{- define "oryx-origin-cluster.redisLabels" -}}
helm.sh/chart: {{ include "oryx-origin-cluster.chart" . }}
{{ include "oryx-origin-cluster.redisSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector redis labels
*/}}
{{- define "oryx-origin-cluster.redisSelectorLabels" -}}
app.kubernetes.io/name: {{ include "oryx-origin-cluster.redis-name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
srs labels
*/}}
{{- define "oryx-origin-cluster.srsLabels" -}}
helm.sh/chart: {{ include "oryx-origin-cluster.chart" . }}
{{ include "oryx-origin-cluster.srsSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector srs labels
*/}}
{{- define "oryx-origin-cluster.srsSelectorLabels" -}}
app.kubernetes.io/name: {{ include "oryx-origin-cluster.srs-name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
srs-proxy labels
*/}}
{{- define "oryx-origin-cluster.srsProxyLabels" -}}
helm.sh/chart: {{ include "oryx-origin-cluster.chart" . }}
{{ include "oryx-origin-cluster.srsProxySelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector srs-proxy labels
*/}}
{{- define "oryx-origin-cluster.srsProxySelectorLabels" -}}
app.kubernetes.io/name: {{ include "oryx-origin-cluster.srs-proxy-name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}