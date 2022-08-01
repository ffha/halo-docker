FROM eclipse-temurin:8-jre-alpine
RUN apk add tini wget
WORKDIR /app
ENV HALO_VER v1.5.4
RUN wget -O halo.jar https://github.com/halo-dev/halo/releases/download/v1.5.4/halo-1.5.4.jar
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["java", "-jar", "/app/halo.jar"]
