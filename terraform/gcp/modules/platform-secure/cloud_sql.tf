locals {
  read_replica_ip_configuration = {
    ipv4_enabled        = false
    require_ssl         = var.sql_require_ssl
    private_network     = data.google_compute_network.vpc.id
    allocated_ip_range  = null
    authorized_networks = []
  }
  sql_replicas = [
    {
      name                  = "0"
      zone                  = "${var.region}-c"
      availability_type     = "REGIONAL"
      tier                  = var.sql_tier
      ip_configuration      = local.read_replica_ip_configuration
      database_flags        = [{ name = "autovacuum", value = "off" }]
      disk_autoresize       = null
      disk_autoresize_limit = null
      disk_size             = null
      disk_type             = "PD_HDD"
      user_labels           = { replica = "0" }
      encryption_key_name   = null
    },
    {
      name                  = "1"
      zone                  = "${var.region}-b"
      availability_type     = "REGIONAL"
      tier                  = var.sql_tier
      ip_configuration      = local.read_replica_ip_configuration
      database_flags        = [{ name = "autovacuum", value = "off" }]
      disk_autoresize       = null
      disk_autoresize_limit = null
      disk_size             = null
      disk_type             = "PD_HDD"
      user_labels           = { replica = "1" }
      encryption_key_name   = null
    },
  ]
}

resource "google_sql_ssl_cert" "sql_client_cert" {
  count       = var.sql_require_ssl ? 1 : 0
  project     = var.project_id
  common_name = "${var.cluster_name}-${var.environment}-sql-ssl"
  instance    = module.sql-db[count.index].instance_name

  depends_on = [
    module.sql-db
  ]
}

# generate password 
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "secret" {
  secret_id = "DB_PASSWORD_${var.environment}"
  labels = {
    environment = var.environment
  }
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "postgres_password" {
  count               = var.environment == "production" ? 0 : 1
  secret              = google_secret_manager_secret.secret.id
  secret_data         = random_password.password.result
}

module "sql-db" {
  count               = var.environment == "production" ? 0 : 1
  source              = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  name                = "${var.cluster_name}-${var.environment}-sql"
  project_id          = var.project_id
  database_version    = "POSTGRES_14"
  enable_default_db   = false
  deletion_protection = false
 #user_password       = google_secret_manager_secret_version.postgres_password[count.index].secret_data
  user_password       = random_password.password.result

  // Master configurations
  tier                            = var.sql_tier
  region                          = var.sql_region
  disk_size                       = var.sql_disk_size
  disk_type                       = "PD_SSD"
  zone                            = "${var.region}-c"
  availability_type               = var.sql_high_available ? "REGIONAL" : null
  maintenance_window_day          = 7
  maintenance_window_hour         = 12
  maintenance_window_update_track = "stable"

  database_flags = [{ name = "autovacuum", value = "off" }]

  user_labels = {
    environment = var.environment
  }

  ip_configuration = {
    ipv4_enabled        = false
    require_ssl         = var.sql_require_ssl
    private_network     = data.google_compute_network.vpc.id
    allocated_ip_range  = null
    authorized_networks = []
  }

  backup_configuration = {
    enabled                        = true
    start_time                     = "02:00"
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = 365
    retention_unit                 = "COUNT"
  }

  // Read replica configurations
  read_replica_name_suffix = "-read-"
  read_replicas            = var.sql_high_available ? local.sql_replicas : []


  additional_databases = [for db in var.sql_databases : {
    name      = db
    charset   = "UTF8"
    collation = "en_US.UTF8"
  }]


}
