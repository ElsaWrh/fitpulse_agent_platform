# Multi-stage Dockerfile for FitPulse backend (Spring Boot)

# ---- Build stage ----
FROM eclipse-temurin:17-jdk AS build
WORKDIR /workspace

# Copy build descriptors and pre-fetch dependencies
COPY pom.xml ./
COPY mvnw mvnw.cmd ./
COPY .mvn .mvn
RUN --mount=type=cache,target=/root/.m2 ./mvnw -q -DskipTests dependency:go-offline

# Copy source and build
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 ./mvnw -q -DskipTests package

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre
ENV TZ=Asia/Shanghai
WORKDIR /app

# Copy the built jar (wildcard handles version changes)
COPY --from=build /workspace/target/*-SNAPSHOT.jar /app/app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
