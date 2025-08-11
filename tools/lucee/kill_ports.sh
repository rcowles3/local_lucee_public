#!/bin/bash

# Recovery: Kill old processes safely and ensure symlinks

# HTTP, HTTPS, JAVA Agents, Debug Ports
DEFAULT_PORTS=(8888 8443 8009 9999 10000)
PORTS=()
FORCE=false
DRY_RUN=false

usage() {
  echo "Usage: $0 [--force] [--dry-run] [port1 port2 ...]"
  exit 1
}

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --force)
      FORCE=true
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    -*)
      usage
      ;;
    *)
      PORTS+=("$arg")
      ;;
  esac
done

if [ ${#PORTS[@]} -eq 0 ]; then
  PORTS=(${DEFAULT_PORTS[@]})
fi

echo "🔍 Scanning for any processes using ports: ${PORTS[*]}"

for PORT in "${PORTS[@]}"; do
  echo "🔎 Checking port $PORT..."

  # Find unique PIDs using the port (any connection state)
  PIDS=$(sudo lsof -iTCP -nP | grep ":$PORT" | awk '{print $2}' | sort -u)

  if [ -z "$PIDS" ]; then
    echo "✅ No process found using port $PORT."
  else
    echo "⚠️ Found process(es) using port $PORT: $PIDS"

    for PID in $PIDS; do
      CMD=$(ps -p $PID -o command=)
      echo "🔍 PID $PID is running: $CMD"

      if [ "$DRY_RUN" = true ]; then
        echo "🧪 DRY RUN: Would kill PID $PID"
      elif [ "$FORCE" = true ]; then
        sudo kill -9 "$PID"
        echo "💀 Force-killed PID $PID"
      else
        read -p "❓ Do you want to kill PID $PID? (y/N): " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
          sudo kill -9 "$PID"
          echo "💀 Killed process $PID"
        else
          echo "🚫 Skipped killing PID $PID"
        fi
      fi
    done
  fi
done

echo "🏁 Done scanning ports."

# (Optional) ROOT symlink recovery
echo "🔗 Ensuring ROOT symlink points to dev directory..."

if [ ! -L "/opt/lucee_server/lucee/webapps/ROOT" ]; then
  echo "⚡ Recreating symlink: /opt/lucee_server/lucee/webapps/ROOT -> $HOME/workspace/lab-1-devel"
  sudo rm -rf "/opt/lucee_server/lucee/webapps/ROOT"
  sudo ln -s "$HOME/workspace/lab-1-devel" "/opt/lucee_server/lucee/webapps/ROOT"
else
  echo "✅ Symlink OK: /opt/lucee_server/lucee/webapps/ROOT"
fi

