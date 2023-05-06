resource "kubernetes_ingress_v1" "dashboard_ingress" {
  depends_on = [google_compute_global_address.ingress_static_ip, kubernetes_service.kubernetes_dashboard, kubectl_manifest.dashboard-ingress-cert]
  metadata {
    name      = "dashboard-ingress-${var.cluster_name}"
    namespace = var.kubernetes_namespace

    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.ingress_static_ip.name
      "kubernetes.io/ingress.class": "gce"
      "networking.gke.io/managed-certificates": "${replace(local.full_dns, ".", "-")}-dashboard"
      "kubernetes.io/ingress.allow-http": "false"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service.kubernetes_dashboard.metadata[0].name
              port {
                number = 443
              }
            }
          }
          path_type = "ImplementationSpecific"
        }
      }
    }
  }
}
resource "kubectl_manifest" "dashboard-backend-config" {
  depends_on = [kubernetes_namespace.kubernetes_dashboard]
  yaml_body = <<YAML
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: backendconfig-${var.kubernetes_resources_name_prefix}kubernetes-dashboard
  namespace: ${var.kubernetes_namespace}
spec:
  timeoutSec: 40
  connectionDraining:
    drainingTimeoutSec: 60
YAML

}

resource "google_compute_global_address" "ingress_static_ip" {
  name   = "ingress-static-ip-address-${var.cluster_name}"
  provider              = google-beta
  project      = var.project_id
  labels =var.kubernetes_resources_labels
}
resource "google_dns_record_set" "ingress_dns" {
  depends_on = [data.google_dns_managed_zone.dns_zone]
  name         = "dashboard.${local.full_dns}."
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  project = data.google_dns_managed_zone.dns_zone.project
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_global_address.ingress_static_ip.address]
}

data "google_dns_managed_zone" "dns_zone" {
  name = "domain-zone"
  project = "dns-project"
}
resource "kubectl_manifest" "dashboard-ingress-cert" {
depends_on = [kubernetes_namespace.kubernetes_dashboard]
  yaml_body = <<YAML
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: ${replace(local.full_dns, ".", "-")}-dashboard
  namespace: ${var.kubernetes_namespace}
spec:
  domains:
    - "dashboard.${local.full_dns}"   
YAML
}
