{{- define "helm.servicetemplate" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "helm.name" .  | replace "-be" "-backend" | replace "-fe" "-frontend" }}
  labels:
    {{- include "helm.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - protocol: TCP
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
  selector:
    {{- include "helm.selectorLabels" . | nindent 4 }}
{{- end }}
