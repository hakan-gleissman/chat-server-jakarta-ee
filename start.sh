#!/usr/bin/env sh
set -eu

: "${PORT:?PORT env saknas}"
echo "Render PORT=${PORT}"

SERVER_XML="/usr/local/tomee/conf/server.xml"
echo "Patching: ${SERVER_XML}"

# Byt bara HTTP-connectorns port (undvik att ersätta alla port="8080" i filen)
sed -i 's/<Connector port="8080"/<Connector port="'"${PORT}"'"/' "${SERVER_XML}" || true

# (Valfritt) Stäng av Tomcats shutdown-port för att slippa "Invalid shutdown command ..."
sed -i 's/<Server port="8005"/<Server port="-1"/' "${SERVER_XML}" || true

echo "== Sanity checks =="
echo "-- webapps dir --"
ls -l /usr/local/tomee/webapps || true

echo "-- ROOT.war exists? --"
ls -lh /usr/local/tomee/webapps/ROOT.war || true

echo "== WAR content (first 40 lines) =="
# jar saknas ofta i JRE-images, så vi använder unzip istället.
# Om unzip också saknas kommer detta bara faila mjukt (|| true).
unzip -l /usr/local/tomee/webapps/ROOT.war | head -n 40 || true

echo "== Does WAR contain index.xhtml? =="
unzip -l /usr/local/tomee/webapps/ROOT.war | grep -n 'index\.xhtml' || true

echo "-- Tomcat connectors after patch --"
grep -n '<Connector' "${SERVER_XML}" | head -n 80 || true

# Starta i foreground (Render behöver foreground-process)
exec catalina.sh run