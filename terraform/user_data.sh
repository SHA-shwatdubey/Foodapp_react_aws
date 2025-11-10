#!/bin/bash
set -e

# Wait for system to be ready
sleep 15

# Update system
apt-get update
apt-get upgrade -y

# Install Node.js 18 and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Verify npm is installed
npm --version
node --version

# Install Nginx (reverse proxy)
apt-get install -y nginx

# Install Git
apt-get install -y git

# Install PM2 globally for process management
npm install -g pm2

# Create app directory
mkdir -p /var/www/food-app
chmod -R 755 /var/www/food-app

# Start Nginx
systemctl start nginx
systemctl enable nginx

# Create a log file
echo "Basic setup complete at $(date)" > /var/log/user-data.log
echo "Node version: $(node --version)" >> /var/log/user-data.log
echo "npm version: $(npm --version)" >> /var/log/user-data.log
