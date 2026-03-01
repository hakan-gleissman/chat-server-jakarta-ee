# syntax=docker/dockerfile:1

########## BUILD STAGE ##########
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# bättre cache: hämta dependencies först
COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

# bygg applikationen (WAR)
COPY src ./src
RUN mvn -B -DskipTests package


########## RUNTIME STAGE ##########
FROM ghcr.io/eclipse-ee4j/glassfish:7.1.0

# Kopiera WAR till autodeploy i domain1
COPY --from=build /app/target/demo-jakarta-facelets-2026-1.0-SNAPSHOT.war \
  /opt/glassfish/glassfish/domains/domain1/autodeploy/chatserver.war

# Skapa startscriptet direkt i imagen (utan chmod-problem)
# Viktigt: vi kör skriptet via /bin/sh så vi behöver inte executable-bit.
RUN set -eux; \
  cat > /start.sh <<'SH' \
#!/usr/bin/env sh
set -eu

PORT="${PORT:?PORT env saknas}"
echo "Render PORT=${PORT}"

# Hitta domain.xml (kan skilja mellan /opt/glassfish och /opt/glassfish7 beroende på image)
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

# Stäng andra listeners som ofta ställer till det i Render (valfritt men brukar hjälpa)
sed -i -E 's/(network-listener name="http-listener-2"[^>]* enabled=")true(")/\1false\2/g' "${DOMAIN_XML}" || true
sed -i -E 's/(network-listener name="admin-listener"[^>]* enabled=")true(")/\1false\2/g' "${DOMAIN_XML}" || true

echo "After:"
grep -n 'network-listener name="http-listener-1"' "${DOMAIN_XML}" || true

# Starta i foreground
exec asadmin start-domain -v domain1
SH
  ;

EXPOSE 8080
CMD ["/bin/sh", "/start.sh"]