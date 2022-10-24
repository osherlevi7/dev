resource "kubernetes_namespace" "jenkins-ns" {
  metadata {
    name = "jenkins"
  }
}

resource "helm_release" "jenkins-chart" {
  name             = "jenkins"
  chart            = "jenkins"
  version          = "4.2.8"
  repository       = "https://charts.jenkins.io"
  namespace        = kubernetes_namespace.jenkins-ns.metadata.0.name
  create_namespace = true
  values = [<<EOF
controller:
  jenkinsUriPrefix: "/jenkins"
  ingress: 
    annotations:
      apiVersion: networking.k8s.io/v1
      cert-manager.io/cluster-issuer: "${local.cluster_issuer_name}"
      cert-manager.io/duration: 2160h
      cert-manager.io/renew-before: 360h
      external-dns.alpha.kubernetes.io/hostname: "${local.full_dns}"
      kubernetes.io/ingress.allow-http: "false"
      kubernetes.io/ingress.class: traefik
      traefik.ingress.kubernetes.io/router.tls: "true"
    enabled: true
    path: /jenkins
    tls:
      - hosts: 
          - ${local.full_dns}
        secretName: jenkins-tls
  installPlugins:
    - kubernetes:latest
    - workflow-job:latest
    - workflow-aggregator:latest
    - credentials-binding:latest
    - git:latest
    - google-oauth-plugin:latest
    - google-source-plugin:latest
    - google-kubernetes-engine:latest
    - google-storage-plugin:latest
  resources:
    requests:
      cpu: "50m"
      memory: "1024Mi"
    limits:
      cpu: "1"
      memory: "3500Mi"
  javaOpts: "-Xms3500m -Xmx3500m"
agent:
  resources:
    requests:
      cpu: "500m"
      memory: "256Mi"
    limits:
      cpu: "1"
      memory: "512Mi"
persistence:
  size: 10Gi
serviceAccount:
  name: jenkins-ns
EOF
  ]

  depends_on = [
    module.gke
  ]
}
