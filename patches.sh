#!/bin/bash

# Patch web.xml: prioritize index.html *and* extend CFMLServlet mappings
echo "🛠️ Extending CFMLServlet servlet‐mappings and updating welcome‐file‐list..."

# Replace the CFMLServlet <servlet‐mapping>…</servlet‐mapping> block
sudo sed -i '' '/<!-- Mappings for the Lucee servlet -->/,/<\/servlet-mapping>/c\
<!-- Mappings for the Lucee servlet -->\
<servlet-mapping>\
  <servlet-name>CFMLServlet</servlet-name>\
  <url-pattern>*.cfm</url-pattern>\
  <url-pattern>*.cfml</url-pattern>\
  <url-pattern>*.html</url-pattern>\
  <url-pattern>*.cfc</url-pattern>\
  <url-pattern>/controller.html/*</url-pattern>\
  <!-- Basic SES Mappings -->\
  <url-pattern>/index.html/*</url-pattern>\
  <url-pattern>/index.cfc/*</url-pattern>\
  <url-pattern>/index.cfm/*</url-pattern>\
  <url-pattern>/index.cfml/*</url-pattern>\
</servlet-mapping>
' "$LUCEE_WEB_XML"

# Rebuild the <welcome-file-list> to put index.html first
sudo sed -i '' '/<welcome-file-list>/,/<\/welcome-file-list>/c\
<welcome-file-list>\
  <welcome-file>index.html</welcome-file>\
  <welcome-file>index.cfm</welcome-file>\
  <welcome-file>index.cfml</welcome-file>\
  <welcome-file>index.jsp</welcome-file>\
  <welcome-file>default.htm</welcome-file>\
  <welcome-file>default.html</welcome-file>\
  <welcome-file>default.jsp</welcome-file>\
</welcome-file-list>
' "$LUCEE_WEB_XML"

echo "✅ Patching web.xml complete!"

# Update server.xml to add HTTPS connector (only if not already present)
if ! grep -q "<!-- HTTPS Connector -->" "$LUCEE_SERVER_XML"; then

  echo "⚙️ Adding HTTPS connector to Tomcat..."

  sed -i.backup '/<!-- Define an AJP 1.3 Connector on port 8009 -->/i\
<!-- HTTPS Connector -->\
<Connector port="8443"\
            protocol="org.apache.coyote.http11.Http11NioProtocol"\
            maxThreads="200"\
            SSLEnabled="true"\
            scheme="https"\
            secure="true"\
            clientAuth="false"\
            sslProtocol="TLS"\
            keystoreFile="'${KEYSTORE_DIR}'/localhost.p12"\
            keystorePass="'${CERT_PASSWORD}'"\
            keystoreType="PKCS12"\
            ciphers="TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"\
            honorCipherOrder="true" />\
<Connector port="443"\
            protocol="org.apache.coyote.http11.Http11NioProtocol"\
            maxThreads="200"\
            SSLEnabled="true"\
            scheme="https"\
            secure="true"\
            clientAuth="false"\
            sslProtocol="TLS"\
            keystoreFile="'${KEYSTORE_DIR}'/localhost.p12"\
            keystorePass="'${CERT_PASSWORD}'"\
            keystoreType="PKCS12"\
            ciphers="TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"\
            honorCipherOrder="true" />\
<!-- End HTTPS Connector -->
' "$LUCEE_SERVER_XML"

  rm -f "${LUCEE_SERVER_XML}.backup"

fi

echo "✅ Patching server.xml complete!"

# Create Lucee Admin Password
echo "📝 Writing Lucee Admin Password to: /opt/lucee_server/lucee/lucee-server/context"
cat <<EOF > $INSTALL_DIR/lucee/lucee-server/context/password.txt
$CERT_PASSWORD
EOF