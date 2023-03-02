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
RUN sed -i 's/$HALO_VERSION-SNAPSHOT/$HALO_VERSION/g' gradle.properties && ./gradlew clean build -x check -x jar

FROM alpine
ARG HALO_VERSION
RUN apk add --no-cache openjdk17-jre-headless tini && addgroup -g 1000 -S halo && adduser -S -D -H -u 1000 -h /home/halo -s /bin/sh -g halo halo
COPY --from=build --chown=halo:halo /app/build/libs/halo-$HALO_VERSION.jar /app/halo.jar
USER halo
WORKDIR /app
EXPOSE 8090
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["sh", "-c", "java -Xmx256m -Xms256m -jar halo.jar ${0} ${@}"]
