#!/usr/bin/env sh
set -eu

# Render sätter PORT (t.ex. 10000). Vi MÅSTE lyssna på den porten.
PORT="${PORT:?PORT env saknas}"
echo "Render PORT=${PORT}"

# Hitta domain.xml oavsett om imagen använder /opt/glassfish eller /opt/glassfish7
DOMAIN_XML="$(find /opt -type f -path '*/glassfish/domains/domain1/config/domain.xml' 2>/dev/null | head -n 1 || true)"
if [ -z "${DOMAIN_XML}" ]; then
  DOMAIN_XML="$(find /opt -type f -path '*/glassfish7/glassfish/domains/domain1/config/domain.xml' 2>/dev/null | head -n 1 || true)"
fi

if [ -z "${DOMAIN_XML}" ]; then
  echo "Kunde inte hitta domain.xml under /opt"
  exit 1
fi

echo "Using domain.xml: ${DOMAIN_XML}"
echo "Before:"
grep -n 'network-listener name="http-listener-1"' "${DOMAIN_XML}" || true

# Sätt http-listener-1 port till Render-port (robust mot attributordning)
sed -i -E \
  "s/(network-listener name=\"http-listener-1\"[^>]* port=\")([0-9]+)(\")/\1${PORT}\3/g" \
  "${DOMAIN_XML}"

# Säkerställ bind address=0.0.0.0 för http-listener-1
if grep -q 'network-listener name="http-listener-1".*address="' "${DOMAIN_XML}"; then
  sed -i -E \
    's/(network-listener name="http-listener-1"[^>]* address=")[^"]+(")/\10.0.0.0\2/g' \
    "${DOMAIN_XML}"
else
  sed -i -E \
    's/(network-listener name="http-listener-1")/\1 address="0.0.0.0"/' \
    "${DOMAIN_XML}"
fi

# Stäng andra listeners som ofta triggar Render "port scan" på fel portar
sed -i -E 's/(network-listener name="http-listener-2"[^>]* enabled=")true(")/\1false\2/g' "${DOMAIN_XML}" || true
sed -i -E 's/(network-listener name="admin-listener"[^>]* enabled=")true(")/\1false\2/g' "${DOMAIN_XML}" || true

echo "After:"
grep -n 'network-listener name="http-listener-1"' "${DOMAIN_XML}" || true

# Starta i foreground
exec asadmin start-domain -v domain1