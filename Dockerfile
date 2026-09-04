# Stage 1: Build the war file
FROM maven:3.8.6-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
# Download dependencies to cache them
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests=true

# Stage 2: Run inside a Tomcat instance to properly compile JSPs
FROM tomcat:9.0-jdk11-openjdk-slim
WORKDIR /usr/local/tomcat/webapps/

# Clear default Tomcat apps to avoid root routing conflicts
RUN rm -rf ROOT*

# Copy the compiled war file from the build layer and rename it to ROOT.war
# This automatically deploys the application directly at the "/" path!
COPY --from=build /app/target/JtSpringProject-0.0.1-SNAPSHOT.war ./ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
