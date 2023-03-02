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

FROM eclipse-temurin:17-jre
ARG HALO_VERSION
RUN apt-get update && apt-get install tini && rm -rf /var/lib/apt/lists/* && groupadd --gid 1000 --system halo && useradd --system --uid 1000 --gid halo --shell /bin/sh --create-home halo
COPY --from=build --chown=halo:halo /app/build/libs/halo-$HALO_VERSION.jar /app/halo.jar
USER halo
WORKDIR /app
EXPOSE 8090
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["sh", "-c", "java -Xmx256m -Xms256m -jar halo.jar ${0} ${@}"]
