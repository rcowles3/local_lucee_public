#!/bin/bash

# Simple copy script
PROJECT_NAME="$1"
PROJECTS_DIR="$HOME/.lucee/projects"

# Copy the workspace file
sudo cp $PROJECTS_DIR/local_lucee.code-workspace $PROJECTS_DIR/$PROJECT_NAME.code-workspace

# Open VS Code
open $PROJECTS_DIR/$PROJECT_NAME.code-workspace