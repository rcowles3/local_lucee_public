#!/bin/bash

echo "✅ Starting Lucee Server..."

# Kill any processes hogging debug ports
echo "🧹 Checking and clearing ports needed ports..."
sudo /opt/lucee_server/tools/lucee/kill_ports.sh --force

# Now start Lucee
sudo /opt/lucee_server/lucee/bin/startup.sh

# Start reload watcher in background
sudo /opt/lucee_server/tools/lucee/watch_files.sh --background

echo "🌐 Lucee is now running at: https://localhost:8443"
echo "To start debugging, open VS Code and use the 'Attach to Lucee Debugger' configuration."