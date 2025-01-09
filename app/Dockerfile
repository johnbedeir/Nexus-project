# # Step 1: Use an OpenJDK base image
# FROM openjdk:17-jdk-slim

# # Step 2: Set a working directory inside the container
# WORKDIR /app

# # Install Maven
# RUN apt update 
# RUN apt install maven -y

# # Step 3: Copy the JAR file into the container
# COPY . . 

# # Compile the JAR file
# RUN mvn package

# # Step 4: Expose the port your app runs on
# EXPOSE 8080

# # Step 5: Run the application
# CMD ["java", "-jar", "target/demo-0.0.1-SNAPSHOT.jar"]

# # ---- STAGE 1: Build the JAR ----
# FROM maven:3.9.3-eclipse-temurin-17 as build
# WORKDIR /app
# COPY . .
# RUN mvn clean package -DskipTests

# # ---- STAGE 2: Create a lean runtime image ----
# FROM openjdk:17-jdk-slim
# WORKDIR /app

# # Copy only the JAR from the build stage
# COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /app/demo.jar

# EXPOSE 8080
# CMD ["java", "-jar", "/app/demo.jar"]

# ---- STAGE 1: Build ----
FROM maven:3.9.3-eclipse-temurin-17 as build
WORKDIR /app

# Copy only pom.xml to cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Now copy source
COPY src ./src

# Build the app
RUN mvn clean package -DskipTests

# ---- STAGE 2: Runtime ----
FROM openjdk:17-jdk-slim
WORKDIR /app

# Copy only the final .jar artifact from the build stage
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /app/javawebapp.jar

# Expose port 8080
EXPOSE 8080

# Run
CMD ["java", "-jar", "/app/javawebapp.jar"]
