# Step 1: Use an OpenJDK base image
FROM openjdk:17-jdk-slim

# Step 2: Set a working directory inside the container
WORKDIR /app

# Install Maven
RUN apt update 
RUN apt install maven -y

# Step 3: Copy the JAR file into the container
COPY . . 

# Compile the JAR file
RUN mvn package

# Step 4: Expose the port your app runs on
EXPOSE 8080

# Step 5: Run the application
CMD ["java", "-jar", "target/demo-0.0.1-SNAPSHOT.jar"]
