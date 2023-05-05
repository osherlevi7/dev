{{- define "helm.configmaptemplate" }}
{{- if .Values.configMap.enabled -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "helm.name" . }}-configmap
data:
  {{- toYaml .Values.configMap.data | nindent 2 }}
{{- end }}
{{- end }}
