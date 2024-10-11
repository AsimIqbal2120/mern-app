# Base image
FROM ubuntu:latest

# Update and install necessary packages in one layer to reduce the image size
RUN apt-get update -y && \
    apt-get install -y nginx git curl gnupg && \
    rm -rf /var/lib/apt/lists/*

# Set working directory for the application
WORKDIR /opt/mern-app

# Clone the application repository
RUN git clone https://github.com/AsimIqbal2120/mern-app.git .

# Install Node.js (latest version) and npm
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Add MongoDB repository and install MongoDB
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list && \
    apt-get update && \
    apt-get install -y mongodb-org && \
    rm -rf /var/lib/apt/lists/*

# Create MongoDB data directory and set ownership
RUN mkdir -p /data/db && \
    chown -R mongodb:mongodb /data/db

# Install backend dependencies
RUN npm install

# Set working directory for the frontend and install dependencies
WORKDIR /opt/mern-app/frontend
RUN npm install && npm run build

# Go back to the app root directory
WORKDIR /opt/mern-app

# Start MongoDB and the Node.js server
CMD ["sh", "-c", "mongod --bind_ip_all & npm run server"]
