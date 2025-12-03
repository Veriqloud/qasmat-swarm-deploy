#!/bin/bash

# Define the target directory and secret files
TARGET_DIR="roles/add_secrets/templates"
mkdir -p "$TARGET_DIR"
SECRETS=(
  "redis_password.secret.j2"
  "jwt.secret.j2"
  "session.secret.j2"
  "storage_encryption_key.secret.j2"
)

# Generate each secret file
for secret in "${SECRETS[@]}"; do
  echo "Generating $secret..."
  openssl rand -hex 64 > "$TARGET_DIR/$secret" || {
    echo "Failed to generate $secret"
    exit 1
  }
done

echo "All secret files generated successfully in $TARGET_DIR/"

# Genrate preshared key
echo "Generating preshared key..."
echo '/key/swarm/psk/1.0.0/' > "$TARGET_DIR/psk.secret.j2"
echo '/base16/' >> "$TARGET_DIR/psk.secret.j2"
openssl rand -hex 32 >> "$TARGET_DIR/psk.secret.j2"

echo "Preshared key generated successfully in $TARGET_DIR/"


