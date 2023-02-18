resource "google_pubsub_topic" "pubsub-topics" {
  for_each = var.environment == "production" ? [] : toset(var.pubsub_topics)

  name    = "${each.key}-${var.environment}"
  project = var.project_id

  labels = {
    environment = var.environment
    cluster     = var.cluster_name
  }
}
