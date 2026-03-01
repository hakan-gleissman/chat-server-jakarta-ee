#!/usr/bin/env sh
set -e

PORT="${PORT:-8080}"
echo "Render PORT=${PORT}"

asadmin start-domain domain1

# Sätt port + bind till alla interfaces
asadmin set server.network-config.network-listeners.network-listener.http-listener-1.port="${PORT}"
asadmin set server.network-config.network-listeners.network-listener.http-listener-1.address=0.0.0.0

# Stäng admin listener (ok om det lyckas, annars fortsätt)
asadmin set server.network-config.network-listeners.network-listener.admin-listener.enabled=false || true

# Ta bort eller gör tolerant:
# asadmin set configs.config.server-config.iiop-service.enabled=false || true

# (Valfritt) logga vad som blev satt
asadmin get server.network-config.network-listeners.network-listener.http-listener-1.port || true
asadmin get server.network-config.network-listeners.network-listener.http-listener-1.address || true

# Starta om i foreground
asadmin stop-domain domain1
exec asadmin start-domain -v domain1