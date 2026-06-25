
FROM maven:3.9.16-eclipse-temurin-26-alpine AS build

WORKDIR /workspace

# Cache de dependencias
COPY pom.xml .
RUN mvn -B -f pom.xml -DskipTests dependency:go-offline

# Copiar proyecto
COPY . .

# Build
RUN mvn -B -DskipTests package



FROM eclipse-temurin:26-jre-alpine

WORKDIR /app

COPY --from=build /workspace/target/*.jar app.jar

ENV SPRING_PROFILES_ACTIVE=dev
ENV PORT=8091
ENV JAVA_OPTS=""

EXPOSE 8091

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -Dserver.port=${PORT} -jar /app/app.jar"]
