# Armor 
resource "google_compute_security_policy" "cluster-sec-policy" {
  provider = google-beta
  project = var.project_id
  name    = "${var.cluster_name}-${var.environment}-waf-policy"
  type = "CLOUD_ARMOR"
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
  rule{
    action = "throttle"
    priority = "9000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
        conform_action        = "allow"
        exceed_action         = "deny(403)"
        rate_limit_threshold {
          count = 20
          interval_sec = 10
        }
      }
    description = "rate limit policy"

  }
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }
}

resource "google_compute_global_address" "cluster-cloud-armor-address" {
  name = "${var.cluster_name}-${var.environment}-armor-address"
  description = " global address for cloud armor ${var.environment}"
}

resource "kubectl_manifest" "cloud-backend-config" {
  yaml_body = <<YAML
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: backendconfig-${google_compute_security_policy.cluster-sec-policy.name}
  namespace: ${data.kubernetes_namespace.ingress-ns.metadata.0.name}
spec:
  timeoutSec: 86400
  connectionDraining:
    drainingTimeoutSec: 1800
  securityPolicy:
    name: "${google_compute_security_policy.cluster-sec-policy.name}"
  healthCheck:
    checkIntervalSec: 10
    timeoutSec: 5
    healthyThreshold: 3
    unhealthyThreshold: 7
    type: HTTP
    requestPath: /ping
    port: 8000
YAML

  depends_on = [
    # helm_release.catch-all-ingress,
    google_compute_global_address.cluster-cloud-armor-address,
    google_compute_security_policy.cluster-sec-policy
  ]
}

resource "kubectl_manifest" "catch-all-ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${var.cluster_name}-catch-all-ingress
  namespace: ${data.kubernetes_namespace.ingress-ns.metadata.0.name}
  annotations:
    kubernetes.io/ingress.allow-http: "false"
    kubernetes.io/ingress.class: "gce"
    networking.gke.io/managed-certificates: ${replace(local.full_dns, ".", "-")}-managed-cert
    kubernetes.io/ingress.global-static-ip-name: ${google_compute_global_address.cluster-cloud-armor-address.name}
    external-dns.alpha.kubernetes.io/hostname: ${local.full_dns}
spec:
  defaultBackend:
    service:
      name: traefik
      port:
        number: 80
YAML

  depends_on = [
    # helm_release.catch-all-ingress,
    google_compute_global_address.cluster-cloud-armor-address,
    google_compute_security_policy.cluster-sec-policy
  ]
}

resource "kubectl_manifest" "ingress-managed-cert" {
  yaml_body = <<YAML
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: ${replace(local.full_dns, ".", "-")}-managed-cert
  namespace: ${data.kubernetes_namespace.ingress-ns.metadata.0.name}
spec:
  domains:
    - ${local.full_dns}
YAML

  depends_on = [
    # kubectl_manifest.ingress-controller,
    google_compute_global_address.cluster-cloud-armor-address,
    google_compute_security_policy.cluster-sec-policy
  ]
}
