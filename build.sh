#!/bin/bash
# Build script for Render deployment

set -e

echo "Installing system dependencies..."
apt-get update
apt-get install -y git curl wget

echo "Installing Python dependencies..."
pip install --upgrade pip
pip install frappe-bench

echo "Initializing Frappe Bench..."
bench init --skip-redis-config-check --skip-mariadb-setup --frappe-branch version-15 frappe-bench

cd frappe-bench

echo "Getting LMS app..."
bench get-app lms https://github.com/frappe/lms

echo "Creating site..."
bench new-site $SITE_NAME \
  --no-mariadb-socket \
  --admin-password $ADMIN_PASSWORD \
  --db-host $DB_HOST \
  --db-port $DB_PORT \
  --db-name $DB_NAME \
  --db-username $DB_USERNAME \
  --db-password $DB_PASSWORD \
  --install-app lms

echo "Building assets..."
bench build --app lms

echo "Setting up production configuration..."
bench --site $SITE_NAME set-config developer_mode 0
bench --site $SITE_NAME set-config maintenance_mode 0

echo "Build completed successfully!"
