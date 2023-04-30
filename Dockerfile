# syntax=docker/dockerfile:1-labs
ARG HALO_VERSION=2.3.1
FROM eclipse-temurin:17 AS build
ARG HALO_VERSION
ADD --keep-git-dir=true https://github.com/halo-dev/halo.git#v$HALO_VERSION /app
WORKDIR /app
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs make && \
   npm i -g pnpm && make -C console build && echo version=$HALO_VERSION > gradle.properties && ./gradlew clean build -x check -x jar

FROM eclipse-temurin:17-jre-alpine
ARG HALO_VERSION
RUN apk add --no-cache tini tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone && apk del tzdata && addgroup -S -g 1000 halo && adduser -S -D -u 1000 -h /home/halo -s /bin/sh -G halo halo
COPY --from=build --chown=halo:halo /app/build/libs/halo-$HALO_VERSION.jar /app/halo.jar
USER halo
WORKDIR /app
EXPOSE 8090
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/sh", "-c", "java -Xmx256m -Xms256m -jar halo.jar ${0} ${@}"]
