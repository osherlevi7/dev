#!/bin/bash -ex

# Fetch the database password securely from Secret Manager.
echo "Fetching database password..."
PG_PASSWORD=$(gcloud secrets versions access "latest" --secret "filemage-database-password")
if [ $? -ne 0 ]; then
  echo "Error fetching database password"
  exit 1
fi

# Create the .pgpass file for PostgreSQL authentication.
echo "Creating .pgpass file..."
echo "database.filemage.internal:5432:filemage-db:filemage:$${PG_PASSWORD}" > ~/.pgpass
echo "database.filemage.internal:5432:postgres:filemage:$${PG_PASSWORD}" >> ~/.pgpass
chmod 600 ~/.pgpass

# Configure PostgreSQL extensions and schemas.
echo "Configuring PostgreSQL extensions..."
PGPASSFILE=~/.pgpass psql -h database.filemage.internal -U filemage -d filemage-db << EOF
CREATE SCHEMA IF NOT EXISTS partman;
CREATE EXTENSION IF NOT EXISTS pg_partman SCHEMA partman;
GRANT ALL ON SCHEMA partman TO filemage;
GRANT ALL ON ALL TABLES IN SCHEMA partman TO filemage;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA partman TO filemage;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA partman TO filemage;
EOF

# Run pg_cron setup.
echo "Setting up pg_cron..."
PGPASSFILE=~/.pgpass psql -h database.filemage.internal -U filemage -d postgres << EOF
CREATE EXTENSION IF NOT EXISTS pg_cron;
SELECT cron.schedule('pg-partman-background', '30 * * * *', 'SELECT partman.run_maintenance(p_analyze := false, p_jobmon := true)');
UPDATE cron.job SET database = 'filemage-db' WHERE jobname = 'pg-partman-background';
EOF

# Remove .pgpass file after use for security.
rm ~/.pgpass

# Generate SSH host key if not exists.
echo "Generating SSH host key..."
if [ ! -f /etc/filemage/ssh_host_rsa_key ]; then
  ssh-keygen -t rsa -b 2048 -f /etc/filemage/ssh_host_rsa_key -N "" -q
  chmod 600 /etc/filemage/ssh_host_rsa_key
fi

# Fetch the application secret securely.
echo "Fetching application secret..."
APP_SECRET=$(gcloud secrets versions access "latest" --secret "filemage-application-secret")
if [ $? -ne 0 ]; then
  echo "Error fetching APP_SECRET from Secret Manager"
  exit 1
fi
echo $APP_SECRET > /opt/filemage/.secret

# Write the database connection info to the application config.
echo "Writing FileMage config..."
cat > /etc/filemage/config.yml << EOF
pg_host: database.filemage.internal
pg_user: filemage
pg_password: $${PG_PASSWORD}
pg_database: filemage-db
pg_ssl_mode: require
sftp_host_keys:
  - /etc/filemage/ssh_host_rsa_key
ftp_proxy_protocol: yes
sftp_proxy_protocol: yes
EOF

# Restart the FileMage service to apply changes.
echo "Restarting FileMage service..."
systemctl restart filemage

# Disable local PostgreSQL to prevent conflicts.
echo "Disabling local PostgreSQL service..."
systemctl stop postgresql
systemctl disable postgresql
