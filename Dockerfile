# Use WebSphere Liberty base image
FROM icr.io/appcafe/websphere-liberty:latest

# Copy server configuration
COPY server.xml /config/

# Copy the WAR file
COPY target/liberty-simple-app.war /config/apps/

# Install features
RUN features.sh

# Expose port
EXPOSE 9080