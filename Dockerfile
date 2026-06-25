# Build stage: Maven + Temurin 26 JDK
# ---------- BUILD STAGE ----------
FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copiamos todo el proyecto
COPY . .

# Compilamos el proyecto (sin tests para acelerar)
RUN mvn clean package -DskipTests


# ---------- RUNTIME STAGE ----------
FROM eclipse-temurin:21-jdk

WORKDIR /app

# Copiamos el .jar generado desde el builder
COPY --from=builder /app/target/*.jar app.jar

# Puerto típico Spring Boot
EXPOSE 8080

# Ejecutamos la app
ENTRYPOINT ["java", "-jar", "app.jar"]

