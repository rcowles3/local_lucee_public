#!/bin/bash

# Local HTTPS
echo "🔍 Checking HTTPS configuration..."

# Check if everything is already configured
if [ -f "$(mkcert -CAROOT)/rootCA.pem" ] && [ -f "$KEYSTORE_DIR/localhost.p12" ]; then
  echo "✅ HTTPS already fully configured. Skipping..."
  return 0
fi

echo "🌍 Setting up global HTTPS configuration..."

# Create directory for keystore
mkdir -p "$KEYSTORE_DIR"

# Install the local CA
echo "🏛️ Installing local certificate authority..."
mkcert -install

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

echo "✅ Global HTTPS setup complete!"
echo "🌟 All *.localhost domains are now ready for HTTPS!"