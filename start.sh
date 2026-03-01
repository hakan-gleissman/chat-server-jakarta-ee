#!/usr/bin/env sh
set -e

PORT="${PORT:-8080}"
echo "Render PORT=${PORT}"

# Starta domain så att asadmin kan ändra config
asadmin start-domain domain1

# Sätt HTTP-porten till Render-porten
asadmin set server.network-config.network-listeners.network-listener.http-listener-1.port="${PORT}"

# Viktigt i containers/Render: bind till alla interfaces
asadmin set server.network-config.network-listeners.network-listener.http-listener-1.address=0.0.0.0

# Rekommenderat: stäng admin-listener (4848)
asadmin set server.network-config.network-listeners.network-listener.admin-listener.enabled=false || true

# Rekommenderat: stäng IIOP (3700) för att slippa GIOP-varningar
asadmin set configs.config.server-config.iiop-service.enabled=false || true

# Logga vad som faktiskt blev satt (bra för Render-loggen)
asadmin get server.network-config.network-listeners.network-listener.http-listener-1.port
asadmin get server.network-config.network-listeners.network-listener.http-listener-1.address

# Starta om i foreground
asadmin stop-domain domain1
exec asadmin start-domain -v domain1