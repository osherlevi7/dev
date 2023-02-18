# cluster's service account
resource "google_service_account" "cluster-sa" {
  account_id   = var.cluster_name
  project      = var.project_id
  display_name = "${var.cluster_name}'s node pools service account"
}
resource "kubernetes_namespace" "ingress-ns" {
  metadata {
    name = var.environment
  }
}
resource "google_service_account" "scheduler-sa" {
  account_id   = "${var.environment}-cloud-scheduler"
  project      = var.project_id
  display_name = "${var.cluster_name}'s scheduler service account to generate tokens"
  
}
# Allow SA service account use the default GCE account
resource "google_service_account_iam_member" "gce-default-account-iam" {
  for_each = toset(["roles/run.serviceAgent", "roles/cloudscheduler.serviceAgent", "roles/editor"])

  service_account_id = google_service_account.scheduler-sa.name
  role               = each.key
  member             = "serviceAccount:${google_service_account.scheduler-sa.email}"
  depends_on = [
    google_service_account.scheduler-sa
  ]
}