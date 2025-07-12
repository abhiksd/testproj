{{/*
Expand the name of the chart.
*/}}
{{- define "generic-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "generic-app.fullname" -}}
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
{{- define "generic-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "generic-app.labels" -}}
helm.sh/chart: {{ include "generic-app.chart" . }}
{{ include "generic-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Values.app.name }}
app.kubernetes.io/environment: {{ .Values.app.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "generic-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "generic-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "generic-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "generic-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate environment-specific resource limits
*/}}
{{- define "generic-app.resources" -}}
{{- if eq .Values.app.environment "prod" }}
limits:
  cpu: 2000m
  memory: 2Gi
requests:
  cpu: 500m
  memory: 512Mi
{{- else if eq .Values.app.environment "staging" }}
limits:
  cpu: 1000m
  memory: 1Gi
requests:
  cpu: 200m
  memory: 256Mi
{{- else }}
limits:
  cpu: 500m
  memory: 512Mi
requests:
  cpu: 100m
  memory: 128Mi
{{- end }}
{{- end }}

{{/*
Generate environment-specific replica count
*/}}
{{- define "generic-app.replicaCount" -}}
{{- if eq .Values.app.environment "prod" }}
{{- default 3 .Values.replicaCount }}
{{- else if eq .Values.app.environment "staging" }}
{{- default 2 .Values.replicaCount }}
{{- else }}
{{- default 1 .Values.replicaCount }}
{{- end }}
{{- end }}

{{/*
Generate image pull policy based on environment
*/}}
{{- define "generic-app.imagePullPolicy" -}}
{{- if eq .Values.app.environment "prod" }}
{{- "IfNotPresent" }}
{{- else }}
{{- "Always" }}
{{- end }}
{{- end }}

{{/*
Generate ingress host based on environment
*/}}
{{- define "generic-app.ingressHost" -}}
{{- if eq .Values.app.environment "prod" }}
{{- printf "%s.example.com" .Values.app.name }}
{{- else }}
{{- printf "%s-%s.example.com" .Values.app.name .Values.app.environment }}
{{- end }}
{{- end }}

{{/*
Generate namespace based on environment
*/}}
{{- define "generic-app.namespace" -}}
{{- if eq .Values.app.environment "prod" }}
{{- "default" }}
{{- else }}
{{- printf "%s-%s" .Values.app.environment .Values.app.name }}
{{- end }}
{{- end }}

{{/*
Generate security context based on environment
*/}}
{{- define "generic-app.securityContext" -}}
{{- if eq .Values.app.environment "prod" }}
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
readOnlyRootFilesystem: true
runAsNonRoot: true
runAsUser: 65534
seccompProfile:
  type: RuntimeDefault
{{- else }}
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
readOnlyRootFilesystem: true
runAsNonRoot: true
runAsUser: 1000
{{- end }}
{{- end }}

{{/*
Generate node selector based on environment
*/}}
{{- define "generic-app.nodeSelector" -}}
{{- if eq .Values.app.environment "prod" }}
kubernetes.io/arch: amd64
node-type: production
{{- else if eq .Values.app.environment "staging" }}
kubernetes.io/arch: amd64
node-type: staging
{{- else }}
kubernetes.io/arch: amd64
{{- end }}
{{- end }}

{{/*
Generate pod anti-affinity for production
*/}}
{{- define "generic-app.podAntiAffinity" -}}
{{- if eq .Values.app.environment "prod" }}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app.kubernetes.io/name
          operator: In
          values:
          - {{ include "generic-app.name" . }}
      topologyKey: kubernetes.io/hostname
{{- end }}
{{- end }}