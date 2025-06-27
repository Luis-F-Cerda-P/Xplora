# Stage 1: Build frontend
FROM node:20-alpine AS frontend-build
WORKDIR /app
COPY frontend/ ./frontend/
WORKDIR /app/frontend
RUN npm install && npm run build

# Stage 2: Build backend
FROM maven:3.9-eclipse-temurin-21 AS backend-build
WORKDIR /app

# Copy backend source code and Maven descriptor
COPY pom.xml .
COPY src ./src

# Copy frontend output into backend's static resource folder
COPY --from=frontend-build /app/frontend/dist ./src/main/resources/static

# Package the Spring Boot application
RUN mvn clean package -DskipTests

# Stage 3: Run the app
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=backend-build /app/target/*.jar app.jar

COPY statement.sql .

# Expose port (adjust if your app uses a different port)
EXPOSE 8080

# Start the application
ENTRYPOINT ["java", "-jar", "app.jar"]
