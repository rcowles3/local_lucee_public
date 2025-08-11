#!/bin/bash

echo "🔄 Restarting Lucee Server..."
sudo /opt/lucee_server/tools/lucee/stop_lucee.sh

sleep 2

sudo /opt/lucee_server/tools/lucee/start_lucee.sh