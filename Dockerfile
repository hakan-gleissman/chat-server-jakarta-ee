FROM ghcr.io/eclipse-ee4j/glassfish:7.1.0

COPY --from=build /app/target/demo-jakarta-facelets-2026-1.0-SNAPSHOT.war \
  /opt/glassfish/glassfish/domains/domain1/autodeploy/chatserver.war

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]