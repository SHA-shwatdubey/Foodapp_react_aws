#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Install Nginx (reverse proxy)
apt-get install -y nginx

# Install Git
apt-get install -y git

# Install PM2 for process management
npm install -g pm2

# Create app directory
mkdir -p /var/www/${project_name}
cd /var/www/${project_name}

# Start Nginx
systemctl start nginx
systemctl enable nginx

echo "Basic setup complete!"
