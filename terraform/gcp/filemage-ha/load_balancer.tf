# Define the external IP address for the load balancer
resource "google_compute_address" "ip_address" {
  name         = "filemage-external-ip"
  network_tier = "STANDARD"
}

# Define the HTTP health check on port 80 for the backend service
resource "google_compute_http_health_check" "default" {
  name               = "port-80-healthcheck"
  request_path       = "/healthz"  # Ensure FileMage has a health check at this path
  timeout_sec        = 30
  check_interval_sec = 30
  port               = 80          # Ensure the health check targets the correct port
}

# Define the backend service for HTTP traffic (port 80) to the FileMage VM instances
resource "google_compute_backend_service" "http_backend" {
  name            = "filemage-http-backend"
  description     = "Backend for FileMage HTTP traffic"
  port_name       = "http"  # The backend will use HTTP (port 80)
  protocol        = "HTTP"  # The backend uses HTTP, not HTTPS
  timeout_sec     = 86400
  health_checks   = [google_compute_http_health_check.default.id]  # Use HTTP health check

  backend {
    group = google_compute_instance_group_manager.filemage.instance_group
  }
  session_affinity = "CLIENT_IP"  # Enable session affinity if needed
  affinity_cookie_ttl_sec = 1800  # Optional: session affinity timeout
}

# Define the backend service for SFTP traffic (port 2222)
resource "google_compute_backend_service" "sftp_backend" {
  name            = "filemage-sftp"
  description     = "Backend for SFTP traffic"
  port_name       = "sftp"
  protocol        = "TCP"
  timeout_sec     = 86400
  health_checks   = [google_compute_health_check.sftp_healthcheck.id]

  backend {
    group = google_compute_instance_group_manager.filemage.instance_group
  }
}

# Define the SFTP TCP health check for port 2222
resource "google_compute_health_check" "sftp_healthcheck" {
  name               = "filemage-sftp"
  timeout_sec        = 30
  check_interval_sec = 30

  tcp_health_check {
    port = "2222"
  }
}

# Define the URL map for routing HTTPS traffic to the HTTP backend service
resource "google_compute_url_map" "https_backend" {
  name            = "filemage-https-backend"
  default_service = google_compute_backend_service.http_backend.self_link

  # Host rule to match all hosts
  host_rule {
    hosts        = ["*"]
    path_matcher = "all-paths"
  }

  # Path matcher to forward all traffic (/*) to the backend service
  path_matcher {
    name            = "all-paths"
    default_service = google_compute_backend_service.http_backend.self_link
  }
}

# Define the HTTPS proxy using the managed SSL certificate
resource "google_compute_target_https_proxy" "filemage_https_proxy" {
  name             = "filemage-https-proxy"
  url_map          = google_compute_url_map.https_backend.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.filemage_ssl_cert.self_link]
}

# Define the forwarding rule for HTTPS traffic (SSL termination at load balancer)
resource "google_compute_forwarding_rule" "https" {
  name         = "filemage-https"
  target       = google_compute_target_https_proxy.filemage_https_proxy.self_link
  port_range   = "443"
  ip_address   = google_compute_address.ip_address.address
  network_tier = "STANDARD"
}

# Define the TCP proxy for SFTP traffic on port 2222
resource "google_compute_target_tcp_proxy" "sftp_proxy" {
  name            = "filemage-sftp"
  backend_service = google_compute_backend_service.sftp_backend.id
  proxy_header    = "PROXY_V1"
}

# Define the forwarding rule for SFTP traffic on port 2222
resource "google_compute_forwarding_rule" "sftp" {
  name         = "filemage-sftp"
  target       = google_compute_target_tcp_proxy.sftp_proxy.self_link
  port_range   = "2222"
  ip_address   = google_compute_address.ip_address.address
  network_tier = "STANDARD"
}
