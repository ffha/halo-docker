FROM eclipse-temurin:11-jre-alpine
RUN apk add tini wget
WORKDIR /app
RUN wget -O halo.jar https://github.com/halo-dev/halo/releases/download/v1.6.0/halo-1.6.0.jar
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["java", "-jar", "halo.jar"]
