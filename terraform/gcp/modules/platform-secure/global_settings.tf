resource "kubernetes_namespace" "environment_ns" {
  metadata {
    name = var.environment
  }
}
locals {
  full_dns = "${replace(var.environment, "-", ".")}.${var.domain}"
}
