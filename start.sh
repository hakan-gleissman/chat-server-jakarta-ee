#!/usr/bin/env sh
set -eu

PORT="${PORT:?PORT env saknas (Render sätter PORT automatiskt)}"
echo "Render PORT=${PORT}"

DOMAIN_XML="/opt/glassfish7/glassfish/domains/domain1/config/domain.xml"
echo "Using domain.xml: ${DOMAIN_XML}"

# Visa vad vi faktiskt kommer ändra (för felsökning i Render-loggen)
echo "Before (http-listener-1 row):"
grep -n 'network-listener name="http-listener-1"' "${DOMAIN_XML}" || true

# 1) Sätt http-listener-1 port till Render-porten
# Matchar både port="8080" och port="${something}" men byter till port="${PORT}"
sed -i -E \
  "s/(network-listener name=\"http-listener-1\"[^>]*port=\")([0-9]+)(\"[^>]*>)/\1${PORT}\3/g" \
  "${DOMAIN_XML}" || true

# 2) Se till att http-listener-1 är bunden till 0.0.0.0
# a) om address="..." redan finns: byt värde
sed -i -E \
  "s/(network-listener name=\"http-listener-1\"[^>]*address=\")([^\"]+)(\"[^>]*>)/\10.0.0.0\3/g" \
  "${DOMAIN_XML}" || true

# b) om address saknas helt: injicera address="0.0.0.0" direkt efter namnet
# (gör inget om den redan finns)
grep -q 'network-listener name="http-listener-1"[^>]*address=' "${DOMAIN_XML}" || \
  sed -i -E \
    's/(network-listener name="http-listener-1")/\1 address="0.0.0.0"/' \
    "${DOMAIN_XML}" || true

# 3) Stäng andra listeners som kan göra att Render “ser” fel port
# http-listener-2 (https/8181) och admin-listener (4848)
sed -i -E \
  's/(network-listener name="http-listener-2"[^>]*enabled=")true(")/\1false\2/g' \
  "${DOMAIN_XML}" || true

sed -i -E \
  's/(network-listener name="admin-listener"[^>]*enabled=")true(")/\1false\2/g' \
  "${DOMAIN_XML}" || true

echo "After (http-listener-1 row):"
grep -n 'network-listener name="http-listener-1"' "${DOMAIN_XML}" || true

# Starta GlassFish i foreground
exec asadmin start-domain -v domain1