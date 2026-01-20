#Builder Stage

FROM maven:3.9.9-eclipse-temurin-21 AS builder

# Sets /app as the working directory inside the container.
WORKDIR /app

# Copies only pom.xml first (for dependency caching).
COPY pom.xml .

# Downloads all dependencies in advance so future builds are faster
RUN mvn dependency:go-offline -B

# Copies your source code into the container.
COPY src ./src

# Builds your Spring Boot app and creates the JAR file
RUN mvn clean package -DskipTests

#Runtime stage
# Starts a fresh image with only Java 21 to keep the final image small.
FROM eclipse-temurin:21-jdk AS runner

# Copies the built JAR from the builder stage into the new image.
COPY --from=builder /app/target/patient-service-0.0.1-SNAPSHOT.jar /app.jar

# Tells Docker that your Spring Boot app runs on port 4000.
EXPOSE 4000

# Command that runs when the container starts:
ENTRYPOINT ["java","-jar","/app.jar"]
