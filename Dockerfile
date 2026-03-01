# syntax=docker/dockerfile:1

########## BUILD STAGE ##########
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# För bättre cache: hämta dependencies först
COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

# Bygg applikationen (WAR)
COPY src ./src
RUN mvn -B -DskipTests package


########## RUNTIME STAGE ##########
# Eclipse GlassFish (Jakarta EE)
FROM ghcr.io/eclipse-ee4j/glassfish:7.1.0

# Kopiera WAR till autodeploy i domain1
# Byt filnamn om du har ett specifikt finalName i pom.xml
COPY --from=build /app/target/demo-jakarta-facelets-2026-1.0-SNAPSHOT.war /opt/glassfish/glassfish/domains/domain1/autodeploy/chatserver.war

# HTTP + Admin Console
EXPOSE 8080 4848

# Starta servern i foreground
CMD ["asadmin", "start-domain", "-v"]