#!/bin/bash

# Setup Local Dashboard
cp local_dashboard/index.html local_dashboard/readme.html $DEV_DIR
cp -r local_dashboard/.local $DEV_DIR

# Convert README.md to HTML and inject it
if [ -f "$HOME/workspace/local_lucee/README.md" ]; then
    echo "📝 Converting README.md to HTML..."
    pandoc "$HOME/workspace/local_lucee/README.md" -f markdown -t html5 --wrap=none -o /tmp/readme_content.html
    sed -i '' -e "/\[INSERT-README\]/{r /tmp/readme_content.html
d;}" "$DEV_DIR/readme.html"
    rm -f /tmp/readme_content.html  # Clean up temp file
    echo "✅ README content injected into dashboard"
else
    echo "⚠️  README.md not found, skipping injection"
fi