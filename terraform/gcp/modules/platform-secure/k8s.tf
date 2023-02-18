data "kubernetes_namespace" "ingress-ns" {
  metadata {
    name = "traefik"
  }
}
