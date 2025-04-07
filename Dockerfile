# Use a base Java image
FROM openjdk:17-jdk-slim

# Copy the built JAR file into the container
COPY build/libs/helloWorld.jar app.jar

# Run the application
CMD ["java", "-jar", "app.jar"]
