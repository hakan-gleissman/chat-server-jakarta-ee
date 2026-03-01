#!/usr/bin/env sh
set -e

PORT="${PORT:-8080}"

# Starta så att asadmin kan ändra config
asadmin start-domain domain1

# Sätt HTTP-porten till Render-porten
asadmin set server.network-config.network-listeners.network-listener.http-listener-1.port="${PORT}"

# (Valfritt men bra) stäng admin-listenern i prod
asadmin set server.network-config.network-listeners.network-listener.admin-listener.enabled=false || true

# (Valfritt) stäng IIOP om du inte behöver det
asadmin set configs.config.server-config.iiop-service.enabled=false || true

asadmin stop-domain domain1

# Starta i foreground
exec asadmin start-domain -v domain1