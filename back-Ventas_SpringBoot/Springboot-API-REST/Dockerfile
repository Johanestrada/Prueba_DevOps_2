# =========================
# Stage 1 - Build
# =========================
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copiar pom primero para cache
COPY pom.xml .

# Descargar dependencias
RUN mvn dependency:go-offline

# Copiar código fuente
COPY src ./src

# Compilar aplicación
RUN mvn clean package -DskipTests


# =========================
# Stage 2 - Runtime
# =========================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Usuario no root
RUN addgroup -S spring && adduser -S spring -G spring

# Copiar jar generado
COPY --from=builder /app/target/*.jar app.jar

# Permisos
RUN chown spring:spring app.jar

# Usuario seguro
USER spring

# Puerto aplicación
EXPOSE 8080

# Ejecutar app
ENTRYPOINT ["java", "-jar", "app.jar"]