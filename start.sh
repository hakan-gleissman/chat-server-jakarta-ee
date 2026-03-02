#!/usr/bin/env sh
set -eu

: "${PORT:?PORT env saknas}"
echo "Render PORT=${PORT}"

SERVER_XML="/usr/local/tomee/conf/server.xml"

echo "Patching: ${SERVER_XML}"

# Sätt HTTP-connectorn (den som normalt har port="8080") till Render-porten.
# Detta matchar typiskt Connector port="8080" protocol="HTTP/1.1"
sed -i 's/port="8080"/port="'"${PORT}"'"/g' "${SERVER_XML}"

# Starta i foreground (Render behöver foreground-process)
exec catalina.sh run