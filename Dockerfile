FROM eclipse-temurin:8-jre-alpine
RUN apk add tini wget
WORKDIR /app
ARG HALO_VER 1.5.4
RUN wget -O halo.jar https://github.com/halo-dev/halo/releases/download/v${HALO_VER}/halo-${HALO_VER}.jar
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["java", "-jar", "/app/halo.jar"]
