
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY Springboot-API-REST-DESPACHO ./Springboot-API-REST-DESPACHO

WORKDIR /app/Springboot-API-REST-DESPACHO

RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

COPY --from=build /app/Springboot-API-REST-DESPACHO/target/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]