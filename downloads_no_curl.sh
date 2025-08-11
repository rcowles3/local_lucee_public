#!/bin/bash

# Clean Up For Fresh Install
echo "🧹 Preparing installation directory..."
rm -rf $INSTALL_DIR
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# Unpack Lucee Express
echo "📦 Unpacking Lucee Express..."
cp $HOME/workspace/local_lucee/downloads/lucee.zip $INSTALL_DIR
unzip -q lucee.zip -d lucee

# Clean Up
rm lucee.zip

# Unpack Java JDK for macOS ARM64
echo "📦 Unpacking Java (macOS ARM64)..."
cp $HOME/workspace/local_lucee/downloads/jdk-mac.tar.gz $INSTALL_DIR

# Set your destination directory
JAVA_DEST_DIR="$INSTALL_DIR/java"
JAVA_TMP_DIR="$(mktemp -d)"

# Extract to temp directory
tar -xzf jdk-mac.tar.gz -C "$JAVA_TMP_DIR"

# Move just the Contents/Home/* into JAVA_DEST_DIR
mkdir -p "$JAVA_DEST_DIR"
cp -R "$JAVA_TMP_DIR"/*/Contents/Home/* "$JAVA_DEST_DIR"

# Clean Up
rm -rf "$JAVA_TMP_DIR" jdk-mac.tar.gz

# Unpack luceedebug.jar
echo "📦 Unpacking luceedebug.jar..."
mkdir -p $INSTALL_DIR/luceedebug
cp $HOME/workspace/local_lucee/downloads/luceedebug.jar $INSTALL_DIR/luceedebug

# Go back to install script dir
cd $LOCAL_LUCEE_DIR