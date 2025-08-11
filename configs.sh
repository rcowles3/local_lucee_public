#!/bin/bash

# Configure setenv.sh
echo "⚙️ Configuring setenv.sh..."
cat <<EOF > $INSTALL_DIR/lucee/bin/setenv.sh
#! /bin/bash

echo "🔧 Running setenv.sh..."
echo "✅ setenv.sh loaded" >> /tmp/lucee_debug_log.txt

# Set paths
LUCEEDEBUG_JAR="$INSTALL_DIR/luceedebug/luceedebug.jar"
JAVA_HOME="$INSTALL_DIR/java"
JRE_HOME="\$JAVA_HOME"

export JAVA_HOME
export JRE_HOME

# Setup CATALINA_OPTS
export CATALINA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=localhost:9999 -javaagent:\$LUCEEDEBUG_JAR=jdwpHost=localhost,jdwpPort=9999,debugHost=localhost,debugPort=10000,jarPath=\$LUCEEDEBUG_JAR,logLevel=debug,logFile=/tmp/luceedebug.log"

echo "CATALINA_OPTS: \$CATALINA_OPTS" >> /tmp/lucee_debug_log.txt
EOF

chmod 740 $INSTALL_DIR/lucee/bin/setenv.sh

# Setup Dev Path (as user) + Lucee context config (symlinked)
echo "⚙️ Creating dev workspace at: $DEV_DIR"
sudo -u $SUDO_USER mkdir -p "$DEV_DIR"
sudo chown -R $SUDO_USER:staff "$DEV_DIR"

# Create config directory in dev env
LUCEE_CONFIG_DIR="$DEV_DIR/.lucee"
mkdir -p "$LUCEE_CONFIG_DIR"

# Write ROOT.xml to the dev env
cat <<EOF > "$LUCEE_CONFIG_DIR/ROOT.xml"
<Context docBase="$DEV_DIR" reloadable="true" />
EOF

# Ensure Lucee conf directory exists and symlink it in
mkdir -p "$INSTALL_DIR/lucee/conf/Catalina/localhost"
ln -sf "$LUCEE_CONFIG_DIR/ROOT.xml" "$INSTALL_DIR/lucee/conf/Catalina/localhost/ROOT.xml"

echo "🔗 Symlinked ROOT.xml into Lucee conf:"
ls -l "$INSTALL_DIR/lucee/conf/Catalina/localhost/ROOT.xml"

# VS Code Workspace Configuration
echo "🛠️ Writing VS Code workspace config..."
mkdir -p "$PROJECTS_DIR"
cat <<EOF > $HOME/.lucee/projects/local_lucee.code-workspace
{
  "folders": [
    {
      "path": "$DEV_DIR"
    }
  ],
  "launch": {
    "version": "0.2.0",
    "configurations": [
      {
        "type": "cfml",
        "request": "attach",
        "name": "Lucee Debugger",
        "hostName": "localhost",
        "port": 10000,
         "pathTransforms": [
          {
            "idePrefix": "$DEV_DIR",
            "serverPrefix": "$DEV_DIR"
          }
        ]
      }
    ]
  },
  "settings": {
    "files.exclude": {
      "**/WEB-INF": true
    }
  }
}
EOF