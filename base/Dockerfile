ARG JAVA_VERSION=21
FROM eclipse-temurin:${JAVA_VERSION}-jre-alpine
RUN apk add --no-cache curl \
    && addgroup -S spring \
    && adduser -S spring -G spring
USER spring:spring
WORKDIR /app
