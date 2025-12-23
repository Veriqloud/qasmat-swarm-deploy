#!/bin/bash

# Define the target directory and secret files
TARGET_DIR="roles/add_secrets/templates"
mkdir -p "$TARGET_DIR"

# Genrate preshared key
echo "Generating preshared key..."
echo '/key/swarm/psk/1.0.0/' > "$TARGET_DIR/psk.secret.j2"
echo '/base16/' >> "$TARGET_DIR/psk.secret.j2"
openssl rand -hex 32 >> "$TARGET_DIR/psk.secret.j2"

echo "Preshared key generated successfully in $TARGET_DIR/"
