# =========================
# Stage 1 - Build
# =========================
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copiar pom.xml primero para aprovechar el cache de Docker
COPY pom.xml .

# Descargar dependencias
RUN mvn dependency:go-offline

# Copiar el código fuente
COPY src ./src

# Compilar la aplicación y empaquetarla, saltando los tests
RUN mvn clean package -DskipTests


# =========================
# Stage 2 - Runtime
# =========================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Crear un usuario y grupo no-root por seguridad
RUN addgroup -S spring && adduser -S spring -G spring

# Copiar el artefacto JAR desde la etapa de construcción
COPY --from=builder /app/target/*.jar app.jar

# Asignar la propiedad del JAR al nuevo usuario
RUN chown spring:spring app.jar

# Cambiar al usuario no-root
USER spring

# Exponer el puerto en el que corre la aplicación
EXPOSE 8080

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]