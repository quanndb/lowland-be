# Stage 1: Build
FROM ubuntu:latest AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    wget \
    unzip

# Install Gradle manually
ARG GRADLE_VERSION=7.6
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip gradle-${GRADLE_VERSION}-bin.zip -d /opt \
    && rm gradle-${GRADLE_VERSION}-bin.zip
ENV PATH="/opt/gradle-${GRADLE_VERSION}/bin:${PATH}"

# Set the working directory
WORKDIR /app

# Copy the source code
COPY . .

# Ensure gradlew has execute permissions
RUN chmod +x ./gradlew

# Build the application
RUN ./gradlew bootJar --no-daemon

# Stage 2: Run
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Expose the application port
EXPOSE 2818

# Copy the built jar from the build stage
COPY --from=build /app/build/libs/LowLand-1.jar app.jar

# Set the entry point to run the jar
ENTRYPOINT ["java", "-jar", "app.jar"]
