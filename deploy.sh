#!/bin/bash
set -e

INSTANCE_IP="98.94.91.124"
KEY_PATH="$HOME/.ssh/food-app-key.pem"
REPO_URL="https://github.com/SHA-shwatdubey/Foodapp_react_aws.git"

echo "=========================================="
echo "��� Deploying React App to AWS EC2"
echo "=========================================="
echo "Instance IP: $INSTANCE_IP"
echo ""

# Wait for instance to be ready
echo "⏳ Waiting for instance to be ready..."
sleep 60

# SSH and setup
echo "��� Setting up Node.js, npm, and Nginx..."
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'REMOTE'
set -e
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get upgrade -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs nginx git

# Create directories
sudo mkdir -p /var/www/food-app /var/log/pm2
sudo chown -R ubuntu:ubuntu /var/www/food-app /var/log/pm2

# Clone repo
echo "Cloning repository..."
cd /var/www/food-app
git clone https://github.com/SHA-shwatdubey/Foodapp_react_aws.git .
cd food-app

# Install and build
echo "Installing npm packages..."
npm install

echo "Building React app..."
npm run build

# Install PM2
echo "Installing PM2..."
sudo npm install -g pm2

# Create PM2 config
cat > /var/www/food-app/ecosystem.config.js << 'CONFIG'
module.exports = {
  apps: [{
    name: 'food-app',
    script: 'npx',
    args: 'serve -s /var/www/food-app/food-app/build -l 3000',
    cwd: '/var/www/food-app',
    instances: 1,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production'
    },
    error_file: '/var/log/pm2/food-app-error.log',
    out_file: '/var/log/pm2/food-app-out.log'
  }]
};
CONFIG

# Start app with PM2
echo "Starting application..."
pm2 start ecosystem.config.js
pm2 save

# Configure Nginx
echo "Configuring Nginx..."
sudo tee /etc/nginx/sites-available/food-app > /dev/null << 'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name _;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

sudo ln -sf /etc/nginx/sites-available/food-app /etc/nginx/sites-enabled/food-app
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

echo "✅ Deployment Complete!"
echo ""
echo "Your app is running at: http://$(hostname -I | awk '{print $1}')"
REMOTE

echo ""
echo "╔════════════════════════════════════════════════════╗"
echo "║     ✅ DEPLOYMENT SUCCESSFUL! ✅                  ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "��� Your React App is live at:"
echo "   http://$INSTANCE_IP"
echo ""
echo "��� App Details:"
echo "   Instance IP: $INSTANCE_IP"
echo "   Backend: PM2 (Port 3000)"
echo "   Frontend: Nginx (Port 80)"
echo ""
echo "��� Useful Commands:"
echo "   SSH: ssh -i $KEY_PATH ubuntu@$INSTANCE_IP"
echo "   View logs: ssh -i $KEY_PATH ubuntu@$INSTANCE_IP 'pm2 logs'"
echo "   Restart app: ssh -i $KEY_PATH ubuntu@$INSTANCE_IP 'pm2 restart food-app'"
echo ""

