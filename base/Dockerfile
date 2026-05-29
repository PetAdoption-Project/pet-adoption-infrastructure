FROM eclipse-temurin:21-jre-alpine@sha256:704db3c40204a44f471191446ddd9cda5d60dab40f0e15c6507b815ed897238b
RUN addgroup -S spring \
    && adduser -S spring -G spring
USER spring:spring
WORKDIR /app
