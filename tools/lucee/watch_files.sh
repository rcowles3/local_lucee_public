#!/bin/bash

# High-level fswatch for Lucee development
# Watches all client files and triggers appropriate actions

WATCH_DIR="$HOME/workspace/lab-1-devel"
LOG_FILE="$HOME/.lucee/fswatch.log"
PID_FILE="$HOME/.lucee/fswatch.pid"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Function to show usage
show_usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --background, -b   bRun in background mode with logging"
  echo "  --stop, -s         Stop background fswatch process"
  echo "  --status           Show status of background process"
  echo "  --log, -l          Show recent log entries (tail -f)"
  echo "  --help, -h         Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                 # Run in foreground (interactive)"
  echo "  $0 --background    # Run in background with logging"
  echo "  $0 --log           # View live log output"
  echo "  $0 --stop          # Stop background process"
}

# Function to stop background process
stop_background() {
  if [ -f "$PID_FILE" ]; then
    local pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      echo "🛑 Stopping fswatch process (PID: $pid)..."
      kill "$pid"
      rm -f "$PID_FILE"
      echo "✅ Background fswatch stopped"
    else
      echo "⚠️ Process not running, cleaning up PID file"
      rm -f "$PID_FILE"
    fi
  else
    echo "ℹ️ No background fswatch process found"
  fi
}

# Function to show status
show_status() {
  if [ -f "$PID_FILE" ]; then
    local pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      echo "✅ Background fswatch is running (PID: $pid)"
      echo "📁 Watching: $WATCH_DIR"
      echo "📄 Log file: $LOG_FILE"
    else
      echo "❌ PID file exists but process not running"
      rm -f "$PID_FILE"
    fi
  else
    echo "❌ Background fswatch is not running"
  fi
}

# Function to show log
show_log() {
  if [ -f "$LOG_FILE" ]; then
    echo "📄 Showing fswatch log (Ctrl+C to exit):"
    tail -f "$LOG_FILE"
  else
    echo "❌ Log file not found: $LOG_FILE"
  fi
}

# Parse command line arguments
case "${1:-}" in
  --background|-b)
    # Check if already running
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "⚠️ Background fswatch is already running (PID: $(cat "$PID_FILE"))"
      echo "💡 Use '$0 --stop' to stop it first"
      exit 1
    fi

    echo "🚀 Starting fswatch in background mode..."
    echo "📄 Log file: $LOG_FILE"
    echo "💡 Use '$0 --log' to view live output"
    echo "💡 Use '$0 --stop' to stop background process"

    # Start in background and save PID
    nohup "$0" --daemon > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    echo "✅ Background fswatch started (PID: $!)"
    exit 0
    ;;
  --stop|-s)
    stop_background
    exit 0
    ;;
  --status)
    show_status
    exit 0
    ;;
  --log|-l)
    show_log
    exit 0
    ;;
  --help|-h)
    show_usage
    exit 0
    ;;
  --daemon)
    # Internal flag for actual daemon process - don't document this
    BACKGROUND_MODE=true
    ;;
  "")
    # No arguments - run in foreground
    BACKGROUND_MODE=false
    ;;
  *)
    echo "❌ Unknown option: $1"
    show_usage
    exit 1
    ;;
esac

# Function to get current Lucee admin URL
get_admin_url() {
  # Since all domains access the same server admin, just find any working one
  local dev_domains=(
    "localhost:8443"
  )

  if [ "$BACKGROUND_MODE" = "false" ]; then
    echo "🔍 Finding accessible Lucee admin..."
  fi

  # Try each domain until we find one that works
  for domain in "${dev_domains[@]}"; do
    if curl -s --connect-timeout 2 "https://$domain/lucee/admin/server.cfm" >/dev/null 2>&1; then
      if [ "$BACKGROUND_MODE" = "false" ]; then
        echo "✅ Using admin via: https://$domain/lucee/admin/server.cfm"
      fi
      return
    fi
  done

  # Final fallback
  if [ "$BACKGROUND_MODE" = "false" ]; then
    echo "⚠️ Using default admin URL"
  fi
  echo "http://localhost:8888/lucee/admin/server.cfm"
}

# Main fswatch logic
LUCEE_ADMIN_URL=$(get_admin_url)

if [ "$BACKGROUND_MODE" = "false" ]; then
  echo "🔍 Starting fswatch for Lucee development..."
  echo "📁 Watching: $WATCH_DIR"
  echo "🎯 File types: .cfm, .cfc, .css, Application.cfc"
  echo "🔗 Using Lucee admin: $LUCEE_ADMIN_URL"
  echo "🛑 Press Ctrl+C to stop watching"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🔍 Starting fswatch for Lucee development (background mode)"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 📁 Watching: $WATCH_DIR"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🔗 Using Lucee admin: $LUCEE_ADMIN_URL"
fi

fswatch -r \
  --include='\.cfm$' \
  --include='\.cfc$' \
  --include='\.css$' \
  --include='Application\.cfc$' \
  --exclude='\.git' \
  --exclude='node_modules' \
  --exclude='\.log$' \
  --exclude='WEB-INF/lucee' \
  --exclude='\.DS_Store' \
  --exclude='\.swp$' \
  --exclude='\.tmp$' \
  "$WATCH_DIR" | while read file; do

  timestamp=$(date "+%H:%M:%S")
  full_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  filename=$(basename "$file")

  if [ "$BACKGROUND_MODE" = "false" ]; then
    echo "[$timestamp] 📝 File changed: $filename"
  else
    echo "[$full_timestamp] 📝 File changed: $filename"
  fi

  case "$file" in
    *.cfm|*.cfc)
      if [ "$BACKGROUND_MODE" = "false" ]; then
        echo "[$timestamp] 🔄 Clearing CFML template cache..."
      else
        echo "[$full_timestamp] 🔄 Clearing CFML template cache..."
      fi
      curl -s "$LUCEE_ADMIN_URL?action=services.cache&subaction=clear&type=template" >/dev/null 2>&1
      ;;

    Application.cfc)
      if [ "$BACKGROUND_MODE" = "false" ]; then
        echo "[$timestamp] 🔄 Application.cfc changed - clearing application cache..."
      else
        echo "[$full_timestamp] 🔄 Application.cfc changed - clearing application cache..."
      fi
      curl -s "$LUCEE_ADMIN_URL?action=services.cache&subaction=clear&type=application" >/dev/null 2>&1
      ;;

    *.css)
      if [ "$BACKGROUND_MODE" = "false" ]; then
        echo "[$timestamp] 🎨 CSS file updated: $filename"
      else
        echo "[$full_timestamp] 🎨 CSS file updated: $filename"
      fi
      ;;
  esac

  if [ "$BACKGROUND_MODE" = "false" ]; then
    echo "[$timestamp] ✅ Done"
  else
    echo "[$full_timestamp] ✅ Done"
  fi
done