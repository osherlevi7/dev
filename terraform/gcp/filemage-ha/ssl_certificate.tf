# ssl_certificate.tf

resource "google_compute_managed_ssl_certificate" "filemage_ssl_cert" {
  name = "filemage-ssl-cert"

  managed {
    domains = ["filemage.domain.com"]  
  }
}
