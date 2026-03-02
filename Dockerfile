# syntax=docker/dockerfile:1

########## BUILD STAGE ##########
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

COPY src ./src
RUN mvn -B -DskipTests package


########## RUNTIME STAGE ##########
FROM tomee:10-jre21-webprofile

# Installera unzip (så start.sh kan lista WAR-innehåll vid felsökning)
RUN apt-get update && \
    apt-get install -y unzip && \
    rm -rf /var/lib/apt/lists/*

# Deploya din app som en egen context path (inte ROOT)
# Ex: chatserver.war => URL blir /chatserver
COPY --from=build /app/target/demo-jakarta-facelets-2026-1.0-SNAPSHOT.war \
  /usr/local/tomee/webapps/chatserver.war

# Startscript (patchar port till $PORT och loggar sanity checks)
COPY --chmod=755 start.sh /usr/local/bin/start.sh

EXPOSE 8080
CMD ["/usr/local/bin/start.sh"]