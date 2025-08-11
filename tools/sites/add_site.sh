#!/bin/bash

# Define variables
CLIENT_NAME="$1"
CLIENT_PATH="$2"
CLASSIC_CLIENT="$3"
OPEN_BROWSER="$4"
LUCEE_SERVER_XML="/opt/lucee_server/lucee/conf/server.xml"
CONTEXT_DIR="/opt/lucee_server/lucee/conf/Catalina/$CLIENT_NAME.localhost"
CONTEXT_XML="$CONTEXT_DIR/ROOT.xml"
CLIENT_WEB_INF="$CLIENT_PATH/WEB-INF"
REWRITE_CONFIG="$CLIENT_WEB_INF/rewrite.config"
WEB_XML="$CLIENT_WEB_INF/web.xml"
DEV_DIR="$HOME/workspace/lab-1-devel"

# Require Arguements
if [[ -z "$CLIENT_NAME" || -z "$CLIENT_PATH" ]]; then
  echo "Usage: $0 <client-name> <docBase-path>"
  exit 1
fi

# Path must exists
if [[ ! -d "$CLIENT_PATH" ]]; then
  echo "❌ Directory not found: $CLIENT_PATH"
  exit 1
fi

# Add <Host> to server.xml if not already present
if ! grep -q "$CLIENT_NAME.localhost" "$LUCEE_SERVER_XML"; then

  TMP_FILE="$LUCEE_SERVER_XML.tmp"

  awk -v name="$CLIENT_NAME.localhost" '
    /<!-- ADD NEW HOSTS HERE -->/ {
      print "  <Host name=\"" name "\" appBase=\"webapps\" unpackWARs=\"true\" autoDeploy=\"true\" />"
    }
    { print }
  ' "$LUCEE_SERVER_XML" > "$TMP_FILE"

  if [[ ! -s "$TMP_FILE" ]]; then
    echo "❌ Failed to modify server.xml"
    exit 1
  fi

  sudo mv "$TMP_FILE" "$LUCEE_SERVER_XML"
  echo "✅ Host entry added for $CLIENT_NAME.localhost"

else
  echo "ℹ️ Host already exists in server.xml, skipping"
fi

# Update /etc/hosts
if ! grep -q "$CLIENT_NAME.localhost" "/etc/hosts"; then
  echo "127.0.0.1 $CLIENT_NAME.localhost" | sudo tee -a "/etc/hosts" > /dev/null
  echo "✅ Added $CLIENT_NAME.localhost to /etc/hosts"
else
  echo "ℹ️ Client $CLIENT_NAME.localhost already in /etc/hosts"
fi

# Ensure context directory exists
mkdir -p "$CONTEXT_DIR"

# Create per-client context XML with mappings and rewrite support
if [ -e "$HOME/workspace/local_lucee/tools/sites/applications/$3.sh" ]; then

source $HOME/workspace/local_lucee/tools/sites/applications/$3.sh

else

echo "❌ Failed to add site. Invalid source: $HOME/workspace/local_lucee/tools/sites/applications/$3.sh"
exit 1

fi

# Restart Lucee
if [ -z "$4" ]; then
  if [[ -x "/opt/lucee_server/tools/lucee/restart_lucee.sh" ]]; then
    echo "🔄 Restarting Lucee..."
    /opt/lucee_server/tools/lucee/restart_lucee.sh
    echo "✅ Lucee restarted"
  else
    echo "⚠️ Restart script missing: /opt/lucee_server/tools/lucee/restart_lucee.sh"
  fi
fi

# Open browser
if [ -z "$4" ]; then
  open -a "Google Chrome" https://$CLIENT_NAME.localhost:8443
fi