#!/bin/bash

# Stop any existing fswatch process first
echo "🛑 Stopping File Watching..."

sudo /opt/lucee_server/tools/lucee/watch_files.sh --stop

# Shutdown
echo "🛑 Stopping Lucee Server..."
echo "⚠️ Shutting Down Lucee Server..."

sudo /opt/lucee_server/lucee/bin/shutdown.sh
