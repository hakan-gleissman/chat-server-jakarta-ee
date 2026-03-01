#!/usr/bin/env sh
set -e

PORT="${PORT:-8080}"
echo "Render PORT=${PORT}"

DOMAIN_XML="/opt/glassfish7/glassfish/domains/domain1/config/domain.xml"

# Byt port på vanliga http listeners (8080/8181 -> $PORT)
# (vissa GF-domäner använder http-listener-2 som faktiskt lyssnar på 8181)
sed -i "s/network-listener name=\"http-listener-1\" port=\"[0-9]\+\"/network-listener name=\"http-listener-1\" port=\"${PORT}\"/g" "$DOMAIN_XML" || true
sed -i "s/network-listener name=\"http-listener-2\" port=\"[0-9]\+\"/network-listener name=\"http-listener-2\" port=\"${PORT}\"/g" "$DOMAIN_XML" || true

# Försök sätta address=0.0.0.0 (om address-attribut inte finns så händer inget)
sed -i "s/network-listener name=\"http-listener-1\" /network-listener name=\"http-listener-1\" address=\"0.0.0.0\" /" "$DOMAIN_XML" || true
sed -i "s/network-listener name=\"http-listener-2\" /network-listener name=\"http-listener-2\" address=\"0.0.0.0\" /" "$DOMAIN_XML" || true

# Starta direkt i foreground (ingen extra start/stop)
exec asadmin start-domain -v domain1