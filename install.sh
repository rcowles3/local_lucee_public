#!/bin/bash

#Check Prerequisites for Local Lucee Server Install
echo "🔍 Checking installation prerequisites..."

if ! command -v brew &>/dev/null; then
  echo "❌ brew is required, please refer to the README.md for installing!"
  exit 1
fi

if ! command -v docker &>/dev/null; then
  echo "❌ docker is required, run: brew install --cask docker"
  exit 1
fi

if ! command -v code &>/dev/null; then
  echo "❌ VS Code is required, run: brew install --cask visual-studio-code"
  exit 1
fi

if ! command -v git &>/dev/null; then
  echo "❌ git is required, run: brew install git"
  exit 1
fi

if ! command -v mkcert &>/dev/null; then
  echo "❌ mkcert is required, run: brew install mkcert"
  exit 1
fi

if ! command -v certutil &>/dev/null; then
  echo "❌ certutil is required, run: brew install nss"
  exit 1
fi

if ! command -v fswatch &>/dev/null; then
  echo "❌ fswatch is required, run: brew install fswatch"
  exit 1
fi

if ! command -v pandoc &>/dev/null; then
  echo "❌ pandoc is required, run: brew install pandoc"
  exit 1
fi

# Define Global Variables
INSTALL_DIR=/opt/lucee_server
DEV_DIR=$HOME/workspace/lab-1-devel
LUCEE_SERVER_XML="$INSTALL_DIR/lucee/conf/server.xml"
LUCEE_WEB_XML="$INSTALL_DIR/lucee/conf/web.xml"
KEYSTORE_DIR="$HOME/.lucee/keystores"
PROJECTS_DIR="$HOME/.lucee/projects"
CERT_PASSWORD="[CREATE-PASSWORD]"

# Downloadable Files
if [ -d "$HOME/workspace/local_lucee/downloads" ]; then
  source $HOME/workspace/local_lucee/downloads_no_curl.sh
else
  source $HOME/workspace/local_lucee/downloads.sh
fi

# Setup Config Files
source $HOME/workspace/local_lucee/configs.sh

# Copy Lucee Tools
cp -r $HOME/workspace/local_lucee/tools /opt/lucee_server
chmod -R +x /opt/lucee_server/tools

# Install Local Certificate Authority for Local HTTPS
source $HOME/workspace/local_lucee/cert.sh

# Patch Lucee Application Files
source $HOME/workspace/local_lucee/patches.sh

# Mount all clients to Lucee Server
source $INSTALL_DIR/tools/sites/mount.sh

# Setup Local Dashboard
source $HOME/workspace/local_lucee/local_dashboard.sh

# Complete!
echo "🎉 Installation complete!"

# Start automatically on install
source $INSTALL_DIR/tools/lucee/start_lucee.sh

# Open browser
open -a "Google Chrome" https://localhost:8443

# Open VS Code
open $PROJECTS_DIR/local_lucee.code-workspace

# Create Alias File
echo "⚙️ Creating alias file for script tools"
cat <<EOF > $HOME/.lucee/tool_aliases
# Lucee Tools
alias lucee-start="/opt/lucee_server/tools/lucee/start_lucee.sh"
alias lucee-stop="/opt/lucee_server/tools/lucee/stop_lucee.sh"
alias lucee-restart="/opt/lucee_server/tools/lucee/restart_lucee.sh"
alias lucee-catalina-out="/opt/lucee_server/tools/lucee/catalina_out.sh"
alias lucee-killports="/opt/lucee_server/tools/lucee/kill_ports.sh"
alias lucee-install-cert="/opt/lucee_server/tools/lucee/install_cert.sh"
alias lucee-watch="/opt/lucee_server/tools/lucee/watch_files.sh"
alias lucee-new-project="/opt/lucee_server/tools/lucee/new_project.sh"

# Add Client Host
alias lucee-add-site="/opt/lucee_server/tools/sites/add_site.sh"
EOF

echo "✅ Alias file created at $HOME/.lucee/tool_aliases"
echo "Append 'source ~/.lucee/tool_aliases' to your bash profile to be able to reference Lucee scripts."