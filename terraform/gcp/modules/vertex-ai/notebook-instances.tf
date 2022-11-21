resource "google_service_account" "analyst_notebook" {
  account_id   = "analyst-notebook-${var.maintainer_name}"
  project      = var.project_id
  display_name = "SA for analysts to access BQ datasets via Vertex notebook"

}


resource "google_notebooks_instance" "analyst_notebook" {
  provider     = google-beta
  name         = "${var.maintainer_name}-research-notebook"
  location     = "${var.region}-a"
  project      = var.project_id
  machine_type = var.machine_type
  vm_image {
    project = "debian-cloud"
    image_name = "debian-10-buster-v20221102"
  }

  install_gpu_driver = var.gpu_driver
  no_public_ip       = var.public_ip
  boot_disk_type     = var.boot_disk_type
  boot_disk_size_gb  = var.boot_disk_size_gb
  data_disk_type     = var.data_disk_type
  data_disk_size_gb  = var.data_disk_size_gb
  # no_proxy_access = true
  network = data.google_compute_network.my_network.id
  subnet  = data.google_compute_subnetwork.my_subnetwork.id
  labels = {
    environment = var.environment
    maintainer  = "${var.maintainer_name}"
  }
  metadata = {
    terraform = "true"
  }
}

# RULE TO BQ
resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.analyst_notebook.email}"
}


# READ on a SPECIFIC BQ dataset.
resource "google_bigquery_dataset_iam_member" "analyst_notebook_data_viewer" {
  provider   = google-beta
  project    = var.project_id
  dataset_id = "dbt_ogolden"
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.analyst_notebook.email}"
}

# Allow only  the intended user to use the SA and by extension, the notebook
resource "google_service_account_iam_binding" "analyst_notebook_service_account_binding-iam" {
  service_account_id = google_service_account.analyst_notebook.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    #CHANGEME - who should have access to assume the Service Account (and access the Notebook)
    "user:name@mail.com",
    "user:name2@mail.com"
  ]
}
// data
data "google_compute_network" "my_network" {
  name = "default"
}
data "google_compute_subnetwork" "my_subnetwork" {
  name   = "default"
  region = var.region
}
