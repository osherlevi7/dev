resource "google_storage_bucket" "backend" {

  name          = var.backend_bucket
  location      = "US"
  storage_class = "STANDARD"
  project       = var.project_id

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  labels = {
    "project" = var.project_id
  }
}
