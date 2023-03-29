{{- define "helm-adh.middlewaretemplate" }}
{{- $shortName := include "helm-adh.name" . | replace "-be" "-backend" | replace "-fe" "-frontend" -}}
{{- if .Values.global.ingress.enabled -}}
{{ if eq $shortName "emr-backend" }}
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: strip-prefix-{{ $shortName }}
spec:
  stripPrefix:
    prefixes:
      - /{{ $shortName }}
{{ end }}
{{- end }}
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: path-regex-{{ $shortName }}
spec:
  replacePathRegex:
    regex: ^/{{ $shortName }}/(.*)
    replacement: /$1
{{- end }}
