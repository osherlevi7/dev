# Define the image for the instances
data "google_compute_image" "filemage_public_image" {
  family  = "filemage-ubuntu"
  project = "filemage-public"
}

# Service account for the instance
resource "google_service_account" "instance" {
  account_id   = "filamge-instance-account"
  display_name = "FileMage Application Server Account"
}

# IAM policy for accessing secrets
data "google_iam_policy" "instance_read_secret" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:${google_service_account.instance.email}",
    ]
  }
}

# Instance template for the managed instance group
resource "google_compute_instance_template" "filemage" {
  depends_on = [
    google_sql_database_instance.read_replica,
    google_secret_manager_secret_version.database_password,
    google_secret_manager_secret_version.application_secret,
  ]

  name_prefix  = "filemage-app-"
  machine_type = "e2-standard-2"
  tags         = ["filemage-app"]

  disk {
    source_image = data.google_compute_image.filemage_public_image.self_link
  }

  network_interface {
    network = google_compute_network.vpc.self_link
  }

  metadata = {
    startup-script = templatefile("${path.module}/scripts/initialize-application.sh", {
      pg_host = google_dns_record_set.database.name
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    email  = google_service_account.instance.email
    scopes = ["cloud-platform"]
  }
}

# Instance group manager to manage instances
resource "google_compute_instance_group_manager" "filemage" {
  name = "filemage-mig"

  base_instance_name = "filemage-app"
  target_size        = 2

  # Named ports for HTTP, HTTPS, and SFTP traffic
  named_port {
    name = "http"   # Named port for HTTP traffic
    port = 80       # VM listens on port 80
  }
  
  named_port {
  name = "https"
  port = 443  # Include HTTPS if needed
  }


  named_port {
    name = "sftp"   # Named port for SFTP traffic
    port = 2222
  }

  version {
    instance_template = google_compute_instance_template.filemage.id
  }

  update_policy {
    type           = "PROACTIVE"
    minimal_action = "REPLACE"
    max_surge_fixed = 2
  }
}
