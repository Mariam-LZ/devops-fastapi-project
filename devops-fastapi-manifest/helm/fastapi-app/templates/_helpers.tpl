{{/*
Return the base chart name.

Uses .Values.nameOverride when provided, otherwise falls back to .Chart.Name.
The result is truncated to match Kubernetes naming limits.
*/}}
{{- define "fastapi-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return the full resource name for this release.

Uses .Values.fullnameOverride when provided.
Otherwise combines the Helm release name with the chart name.
*/}}
{{- define "fastapi-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "fastapi-app.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels applied to chart resources.

These labels help identify which Helm release manages each Kubernetes resource.
*/}}
{{- define "fastapi-app.labels" -}}
app.kubernetes.io/name: {{ include "fastapi-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/*
Selector labels used by backend resources.

These labels must match the backend pod labels used by Services,
Deployments, HPAs, and monitoring resources.
*/}}
{{- define "fastapi-app.backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fastapi-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Selector labels used by frontend resources.

These labels must match the frontend pod labels used by Services,
Deployments, HPAs, and monitoring resources.
*/}}
{{- define "fastapi-app.frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fastapi-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: frontend
{{- end }}