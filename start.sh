#!/usr/bin/env sh
set -e

PORT="${PORT:?PORT env saknas}"
echo "Render PORT=${PORT}"

DOMAIN_XML="/opt/glassfish7/glassfish/domains/domain1/config/domain.xml"

# Sätt http-listener-1 till Render-port
sed -i "s/network-listener name=\"http-listener-1\" port=\"[0-9]\+\"/network-listener name=\"http-listener-1\" port=\"${PORT}\"/g" "$DOMAIN_XML"

# Bind till 0.0.0.0 (om address-attribut saknas blir det ingen ändring, men ok)
sed -i "s/network-listener name=\"http-listener-1\" /network-listener name=\"http-listener-1\" address=\"0.0.0.0\" /" "$DOMAIN_XML" || true

# Stäng andra listeners som annars kan ställa till det
sed -i "s/network-listener name=\"http-listener-2\" enabled=\"true\"/network-listener name=\"http-listener-2\" enabled=\"false\"/g" "$DOMAIN_XML" || true
sed -i "s/network-listener name=\"admin-listener\" enabled=\"true\"/network-listener name=\"admin-listener\" enabled=\"false\"/g" "$DOMAIN_XML" || true

exec asadmin start-domain -v domain1