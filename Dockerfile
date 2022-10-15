FROM alpine as download
RUN apk add tini wget
WORKDIR /app
RUN wget -O halo.jar https://github.com/halo-dev/halo/releases/download/v1.6.0/halo-1.6.0.jar
FROM gcr.io/distroless/java17-debian11:nonroot
WORKDIR /app
COPY --from=download /app /app
CMD ["halo.jar"]
