# syntax=docker/dockerfile:1

########## BUILD STAGE ##########
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

COPY src ./src
RUN mvn -B -DskipTests package

########## RUNTIME STAGE ##########
FROM ghcr.io/eclipse-ee4j/glassfish:7.1.0

COPY --from=build /app/target/demo-jakarta-facelets-2026-1.0-SNAPSHOT.war \
  /opt/glassfish/glassfish/domains/domain1/autodeploy/chatserver.war

RUN set -eux; \
  printf '%s\n' \
'#!/usr/bin/env sh' \
'set -e' \
'' \
'PORT="${PORT:-8080}"' \
'' \
'asadmin start-domain domain1' \
'asadmin set server.network-config.network-listeners.network-listener.http-listener-1.port="${PORT}"' \
'asadmin set server.network-config.network-listeners.network-listener.admin-listener.enabled=false || true' \
'asadmin set configs.config.server-config.iiop-service.enabled=false || true' \
'asadmin stop-domain domain1' \
'' \
'exec asadmin start-domain -v domain1' \
  > /start.sh; \
  chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]