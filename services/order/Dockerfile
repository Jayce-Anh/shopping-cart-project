# --- Build stage: compile and package the jar with Maven ---
FROM maven:3.8.6-eclipse-temurin-8 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -B -DskipTests clean package

# --- Runtime stage: run the packaged jar ---
FROM eclipse-temurin:8-jre
WORKDIR /app
COPY --from=build /app/target/*-exec.jar app.jar
COPY .env .env
EXPOSE 6000
ENTRYPOINT ["sh", "-c", "set -a && [ -f .env ] && . ./.env && set +a && exec java -Djava.security.egd=file:/dev/./urandom -jar /app/app.jar"]
