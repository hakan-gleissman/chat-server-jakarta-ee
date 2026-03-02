# syntax=docker/dockerfile:1

########## BUILD STAGE ##########
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

COPY src ./src
RUN mvn -B -DskipTests package


########## RUNTIME STAGE ##########
# OBS: välj en TomEE 10 (Jakarta) webprofile/plume som matchar dina behov.
# Om taggen nedan inte finns hos dig, byt till en existerande TomEE 10-tag.
FROM tomee:10-jre21-webprofile

# Lägg appen som ROOT så att den svarar på /
COPY --from=build /app/target/demo-jakarta-facelets-2026-1.0-SNAPSHOT.war \
  /usr/local/tomee/webapps/ROOT.war

# Lägg startscript med rätt rättigheter direkt (slipper chmod-problemet)
COPY --chmod=755 start.sh /usr/local/bin/start.sh

EXPOSE 8080
CMD ["/usr/local/bin/start.sh"]