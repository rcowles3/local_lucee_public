#!/bin/bash

# Define Download Versions
LUCEE_VERSION=https://cdn.lucee.org/lucee-express-5.4.6.9.zip
JAVA_VERSION=https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.26%2B4/OpenJDK11U-jdk_aarch64_mac_hotspot_11.0.26_4.tar.gz
LUCEEDEBUG_VERSION=https://github.com/softwareCobbler/luceedebug/releases/download/agent%2F2.0.14/luceedebug-2.0.14.jar

# Downloads folder for faster future installs
echo "✅ Download directory created at: $HOME/workspace/local_lucee/downloads"
mkdir $HOME/workspace/local_lucee/downloads

# Clean Up For Fresh Install
echo "🧹 Preparing installation directory..."
rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# Download Lucee Express
echo "📦 Downloading Lucee Express..."
curl -SL --progress-bar $LUCEE_VERSION -o lucee.zip
unzip -q lucee.zip -d lucee

# Move Download
mv lucee.zip $HOME/workspace/local_lucee/downloads

# Download Java JDK for macOS ARM64
echo "📦 Downloading Java (macOS ARM64)..."
curl -SL --progress-bar $JAVA_VERSION -o jdk-mac.tar.gz

# Set your destination directory
JAVA_DEST_DIR="$INSTALL_DIR/java"
JAVA_TMP_DIR="$(mktemp -d)"

# Extract to temp directory
tar -xzf jdk-mac.tar.gz -C "$JAVA_TMP_DIR"

# Move just the Contents/Home/* into JAVA_DEST_DIR
echo "✅ JDK extracted to: $JAVA_DEST_DIR"
mkdir -p "$JAVA_DEST_DIR"
cp -R "$JAVA_TMP_DIR"/*/Contents/Home/* "$JAVA_DEST_DIR"

# Move Download
mv jdk-mac.tar.gz $HOME/workspace/local_lucee/downloads

# Download luceedebug.jar
echo "📦 Downloading luceedebug.jar..."
mkdir -p $INSTALL_DIR/luceedebug
cd $INSTALL_DIR/luceedebug
curl -SL --progress-bar $LUCEEDEBUG_VERSION -o luceedebug.jar

# Move Download
cp $INSTALL_DIR/luceedebug/luceedebug.jar $HOME/workspace/local_lucee/downloads

# Go back to install script dir
cd $LOCAL_LUCEE_DIR