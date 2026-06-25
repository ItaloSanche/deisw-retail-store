# ==============================
# STAGE 1: BUILD (Maven + Temurin 24)
# ==============================
FROM maven:3.9.11-eclipse-temurin-24-noble AS build

WORKDIR /workspace

# Copiamos pom.xml y descargamos dependencias (cache)
COPY pom.xml .
RUN mvn -B -f pom.xml -DskipTests dependency:go-offline

# Copiamos el resto del proyecto
COPY . .

# Compilamos el proyecto
RUN mvn -B -DskipTests package


# ==============================
# STAGE 2: RUNTIME (JRE ligero)
# ==============================
FROM eclipse-temurin:24-jre-noble

WORKDIR /app

# Copiamos el JAR generado
COPY --from=build /workspace/target/*.jar app.jar

# Variables de entorno configurables
ENV SPRING_PROFILES_ACTIVE=dev
ENV PORT=8091
ENV JAVA_OPTS=""

EXPOSE 8091

# Ejecución flexible
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -Dserver.port=${PORT} -jar /app/app.jar"]
