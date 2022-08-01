FROM eclipse-temurin:8-jre-alpine
RUN apk add tini wget
WORKDIR /app
ENV HALO_VER v1.5.4
RUN wget -O halo.jar https://github.com/halo-dev/halo/releases/download/${HALO_VER}/halo-${HALO_VER}.jar
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["java", "-jar", "/app/halo.jar"]
