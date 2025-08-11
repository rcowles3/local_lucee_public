#!/bin/bash

# Replace client path last / with client dir
FORMAT_NAME="${CLIENT_NAME//-devel/}"

# Create per-client context XML with mappings and rewrite support
echo "📝 Creating context XML: $CONTEXT_XML"

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

# Only redirect HTTP to HTTPS if specifically coming from HTTP port
RewriteCond %{SERVER_PORT} ^8888$
RewriteCond %{HTTP_HOST} ^(.+\.localhost)$
RewriteRule ^/(.*)$ https://%{HTTP_HOST}:8443/\$1 [R=301,L]

# Skip /gallery/* so ProxyServlet handles it
RewriteRule ^/gallery/ - [L]

# Redirect gallery images to live url to load image locally
RewriteRule ^/gallery/(.*)$ https://$FORMAT_NAME.[CLIENT-URL].com/gallery/\$1 [R,L]

# Skip / do not rewrite if the request is for an existing file (-f) or directory (-d)
RewriteCond %{REQUEST_PATH} -f [OR]
RewriteCond %{REQUEST_PATH} -d
RewriteRule .* - [L]

# Skip controller.html itself and favicon.ico to prevent loop
RewriteRule ^/(?:controller\.html|favicon\.ico)$ - [L]

# Skip any request under these “static/CFML” folders
RewriteRule ^/(?:filemanager|gallery|lucee|error)(?:/.*)?$ - [L]

# Do NOT rewrite the root path
RewriteRule ^/?$ - [L]

# Custom Rewrite Rules Here
RULES

# Create local app_config from devel
rm $CLIENT_PATH/app_config/${CLIENT_NAME}_localhost.cfm
cp -v $CLIENT_PATH/app_config/${CLIENT_NAME}_[CLIENT-URL].cfm $CLIENT_PATH/app_config/${CLIENT_NAME}_localhost.cfm

# Update local mappings
sed -i '' "s|[DEV-MAPPINGS]|$DEV_DIR|g" $CLIENT_PATH/app_config/${CLIENT_NAME}_localhost.cfm

# Change ownership back to user
sudo chown "$USER":staff $CLIENT_PATH/app_config/${CLIENT_NAME}_localhost.cfm