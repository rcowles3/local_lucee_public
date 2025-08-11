#!/bin/bash

# Replace client path last / with client dir
FORMAT_NAME="${CLIENT_NAME//-portal-devel/}"

# Create per-client context XML with mappings and rewrite support
echo "📝 Creating Portal Context XML: $CONTEXT_XML"

cat > "$CONTEXT_XML" <<XML
<Context docBase="$CLIENT_PATH" reloadable="true">
  <Valve className="org.apache.catalina.valves.rewrite.RewriteValve" />
  <Environment name="DEVELOPMENT_MODE" value="true" type="java.lang.String" />
  <Environment name="HTTPS_ENABLED" value="true" type="java.lang.String" />
  <Environment name="LOCAL_PORT" value="8443" type="java.lang.String" />
  <Resources>
    <PreResources className="org.apache.catalina.webresources.DirResourceSet"
                  base="$DEV_DIR/filemanager"
                  webAppMount="/filemanager" />
    <PreResources className="org.apache.catalina.webresources.DirResourceSet"
                  base="$DEV_DIR/filemanager/cfcs"
                  webAppMount="/cfcs" />
  </Resources>
</Context>
XML

# Create rewrite config if missing
echo "📝 Writing rewrite rules to: $REWRITE_CONFIG"
mkdir -p "$(dirname "$REWRITE_CONFIG")"
cat > "$REWRITE_CONFIG" <<RULES
# ==========================
#  Tomcat RewriteValve Rules
# ==========================

# Strip any explicit “index.html” off the end
RewriteCond %{THE_REQUEST} /index\.html [NC]
RewriteRule ^/(.*)index\.html$ /\$1 [R=301,L]

# Only redirect HTTP to HTTPS if specifically coming from HTTP port
RewriteCond %{SERVER_PORT} ^8888$
RewriteCond %{HTTP_HOST} ^(.+\.localhost)$
RewriteRule ^/(.*)$ https://%{HTTP_HOST}:8443/\$1 [R=301,L]

# If it came in on default-HTTPS (443), send it to :8443
RewriteCond %{SERVER_PORT} =443
RewriteRule ^/(.*)$ https://%{HTTP_HOST}:8443/\$1 [R=302,L]

# Redirect gallery images to live url to load image locally
RewriteCond %{HTTP_HOST} ^([^-]+)-portal(?:-devel)?\.localhost(?::\d+)?$
RewriteRule ^/gallery/(.*)$ https://%1.[CLIENT-URL].com/gallery/\$1 [R=302,L]

# Strip timestamp queries from static assets
RewriteRule ^/(.+\.(?:css|js|png|jpg|gif))(?:\?.*)$ /\$1? [L]

# Skip real files & directories
RewriteCond %{REQUEST_PATH} -f [OR]
RewriteCond %{REQUEST_PATH} -d
RewriteRule .* - [L]

# Skip controller.html itself and favicon.ico (prevent loop)
RewriteRule ^/(?:controller\.html|favicon\.ico)$ - [L]

# Skip other static/CFML folders
RewriteRule ^/(?:filemanager|gallery|lucee|error)(?:/.*)?$ - [L]

# Custom Rewrite Rules Here
RULES

# Create local app_config from devel
cp -v $CLIENT_PATH/app_config/${FORMAT_NAME}-devel_[CLIENT-URL].cfm $CLIENT_PATH/app_config/${CLIENT_NAME}_localhost.cfm

# Update local mappings
sed -i '' "s|[DEV-MAPPINGS]|$DEV_DIR|g" $CLIENT_PATH/app_config/${CLIENT_NAME}_localhost.cfm

# Change ownership back to user
sudo chown "$USER":staff $CLIENT_PATH/app_config/${CLIENT_NAME}_localhost.cfm