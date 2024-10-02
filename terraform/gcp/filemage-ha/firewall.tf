resource "google_compute_firewall" "app" {
  name          = "filemage-app"
  network       = google_compute_network.vpc.self_link
  priority      = "1001"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["443", "2222", "22", "80"]  # Ensure both HTTP and HTTPS are allowed
  }

  target_tags = ["filemage-app"]
}


# FTP clients connect directly to app VMs, bypassing load balancer.
# resource "google_compute_firewall" "ftp_passive" {
#   name          = "filemage-ftp-passive"
#   network       = google_compute_network.vpc.self_link
#   priority      = "1002"
#   source_ranges = ["0.0.0.0/0"]

#   allow {
#     protocol = "tcp"
#     ports    = ["32768-65535"]
#   }

#   target_tags = ["filemage-app"]
# }

resource "google_compute_firewall" "postgresql" {
  name          = "filemage-postgresql"
  network       = google_compute_network.vpc.self_link
  priority      = "1001"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  target_tags = ["filemage-postgresql"]
}

resource "google_compute_firewall" "allow-egress" {
  name    = "allow-egress"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["443"]  # Allow outbound HTTPS
  }

  direction = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
}

# resource "google_compute_firewall" "allow-lb" {
#   name          = "allow-lb"
#   network       = google_compute_network.vpc.self_link
#   priority      = "1000"
#   direction     = "INGRESS"
#   source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]  # IP ranges for Google Cloud Load Balancers
#   allow {
#     protocol = "tcp"
#     ports    = ["80", "443"]  # Ports required for HTTP and HTTPS
#   }
#   target_tags = ["filemage-app"] 
# }
