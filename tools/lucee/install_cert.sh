#!/bin/bash

# Reinstall Expired Certificate
INSTALL_DIR=/opt/lucee_server
KEYSTORE_DIR="$HOME/.lucee/keystores"
CERT_PASSWORD="[CREATE-PASSWORD]"

# Generate wildcard certificate for all portal sites
echo "🔑 Generating wildcard SSL certificate..."
cd "$KEYSTORE_DIR"
mkcert -key-file localhost.key -cert-file localhost.crt "localhost" "*.localhost"

# Convert to PKCS12 format for Tomcat
openssl pkcs12 -export \
    -in "$KEYSTORE_DIR/localhost.crt" \
    -inkey "$KEYSTORE_DIR/localhost.key" \
    -out "$KEYSTORE_DIR/localhost.p12" \
    -password pass:$CERT_PASSWORD

# Restart Lucee
$INSTALL_DIR/tools/lucee/restart_lucee.sh