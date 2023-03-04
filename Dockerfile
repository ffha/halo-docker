# syntax=docker/dockerfile:1-labs
ARG HALO_VERSION=2.3.0
FROM node:lts-slim AS build-console
ARG HALO_VERSION
ADD --keep-git-dir=true https://github.com/halo-dev/console.git#v$HALO_VERSION /app/console
WORKDIR /app/console
RUN npm install -g pnpm && pnpm install && pnpm build:packages && pnpm build

FROM eclipse-temurin:17 AS build
ARG HALO_VERSION
ADD --keep-git-dir=true https://github.com/halo-dev/halo.git#v$HALO_VERSION /app
WORKDIR /app
COPY --from=build-console /app/console/dist /app/src/main/resources/console
RUN echo version=$HALO_VERSION > gradle.properties && ./gradlew clean build -x check -x jar

FROM busybox:glibc
ARG HALO_VERSION
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:17-jre $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /sbin/tini
RUN chmod +x /sbin/tini && addgroup -S -g halo && adduser -S -D -u 1000 -h /home/halo -s /bin/sh -G halo halo
COPY --from=build --chown=halo:halo /app/build/libs/halo-$HALO_VERSION.jar /app/halo.jar
USER halo
WORKDIR /app
EXPOSE 8090
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/sh", "-c", "java -Xmx256m -Xms256m -jar halo.jar ${0} ${@}"]
