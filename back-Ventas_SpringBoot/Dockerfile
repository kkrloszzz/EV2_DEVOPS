# Stage 1: Build (Construcción del archivo .jar con Maven)
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copiamos la subcarpeta que contiene el código de Spring Boot de Ventas
COPY Springboot-API-REST ./Springboot-API-REST

# Nos movemos dentro de la subcarpeta donde vive el archivo pom.xml
WORKDIR /app/Springboot-API-REST

# Compilamos y empaquetamos el proyecto 
RUN mvn clean package -DskipTests

# Stage 2: Runtime (Ejecución de la app)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copiamos el archivo .jar que se generó en la etapa 1
COPY --from=build /app/Springboot-API-REST/target/*.jar app.jar

# Exponemos el puerto estándar de Spring Boot
EXPOSE 8080

# Comando para iniciar la aplicación Java
CMD ["java", "-jar", "app.jar"]