# syntax=docker/dockerfile:1-labs
FROM node:lts-slim AS build-console
ADD --keep-git-dir=true https://github.com/halo-dev/console.git#v2.2.1 /app/console
WORKDIR /app/console
RUN npm install -g pnpm && pnpm install && pnpm build:packages && pnpm build

FROM eclipse-temurin:17 AS build
ADD --keep-git-dir=true https://github.com/halo-dev/halo.git#v2.2.1 /app
WORKDIR /app
COPY --from=build-console /app/console/dist /app/src/main/resources/console
RUN sed -i 's/2.2.1-SNAPSHOT/2.2.1/g' gradle.properties && ./gradlew clean build -x check -x jar

FROM eclipse-temurin:17-jre
RUN apt-get install tini && groupadd --gid 1000 --system halo && useradd --system --uid 1000 --gid halo --shell /bin/sh --create-home halo
COPY --from=build --chown=halo:halo /app/build/libs/halo-2.2.1.jar /app/halo.jar
USER halo
WORKDIR /app
EXPOSE 8090
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["java", "-jar", "halo.jar"]
