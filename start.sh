#!/usr/bin/env sh
set -eu

: "${PORT:?PORT env saknas}"
echo "Render PORT=${PORT}"

SERVER_XML="/usr/local/tomee/conf/server.xml"
echo "Patching: ${SERVER_XML}"

# Byt bara HTTP-connectorns port (undvik att ersätta alla port="8080" i filen)
# Vanligt i TomEE/Tomcat-images att HTTP-connectorn står som <Connector port="8080" ...>
sed -i 's/<Connector port="8080"/<Connector port="'"${PORT}"'"/' "${SERVER_XML}" || true

# (Valfritt men bra) Stäng av Tomcats shutdown-port för att slippa "Invalid shutdown command ..."
# Sätter <Server port="8005" ...> -> <Server port="-1" ...>
sed -i 's/<Server port="8005"/<Server port="-1"/' "${SERVER_XML}" || true

echo "== Sanity checks =="
echo "-- webapps dir --"
ls -l /usr/local/tomee/webapps || true

echo "-- ROOT.war exists? --"
ls -l /usr/local/tomee/webapps/ROOT.war || true

echo "-- Does ROOT.war contain index.xhtml? --"
jar tf /usr/local/tomee/webapps/ROOT.war | grep -n 'index\.xhtml' || true

echo "-- Tomcat HTTP connector after patch --"
grep -n '<Connector' "${SERVER_XML}" | head -n 50 || true

# Starta i foreground (Render behöver foreground-process)
exec catalina.sh run