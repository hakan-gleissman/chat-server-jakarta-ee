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

# Kopiera WAR till autodeploy
COPY --from=build /app/target/demo-jakarta-facelets-2026-1.0-SNAPSHOT.war \
  /opt/glassfish7/glassfish/domains/domain1/autodeploy/chatserver.war

# Lägg script i en mapp vi kontrollerar
USER root
RUN mkdir -p /opt/app

COPY start.sh /opt/app/start.sh
RUN chmod +x /opt/app/start.sh

EXPOSE 8080
CMD ["/opt/app/start.sh"]