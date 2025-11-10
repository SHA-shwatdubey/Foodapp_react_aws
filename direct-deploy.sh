#!/bin/bash

# Direct deployment to EC2 instance
INSTANCE_IP="98.91.199.145"
KEY_FILE="~/.ssh/food-app-key.pem"

echo "============================================"
echo "🚀 DEPLOYING REACT APP TO EC2"
echo "Instance: $INSTANCE_IP"
echo "============================================"
echo ""

# Step 1: Clone repository
echo "📦 Step 1: Cloning repository..."
ssh -i $KEY_FILE -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'DEPLOY_STEP_1'
cd /var/www
sudo rm -rf food-app
sudo mkdir -p food-app
sudo chown ubuntu:ubuntu food-app
cd food-app
git clone https://github.com/SHA-shwatdubey/Foodapp_react_aws.git .
DEPLOY_STEP_1

echo "✅ Repository cloned"
echo ""

# Step 2: Install dependencies
echo "📥 Step 2: Installing dependencies..."
ssh -i $KEY_FILE -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'DEPLOY_STEP_2'
cd /var/www/food-app/food-app
npm install
DEPLOY_STEP_2

echo "✅ Dependencies installed"
echo ""

# Step 3: Build React app
echo "🏗️  Step 3: Building React app..."
ssh -i $KEY_FILE -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'DEPLOY_STEP_3'
cd /var/www/food-app/food-app
npm run build
DEPLOY_STEP_3

echo "✅ React app built"
echo ""

# Step 4: Configure PM2
echo "⚙️  Step 4: Configuring PM2..."
ssh -i $KEY_FILE -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'DEPLOY_STEP_4'
mkdir -p /var/log/pm2
cd /var/www/food-app

cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'food-app',
    script: 'npx',
    args: 'serve -s food-app/build -l 3000',
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
EOF

pm2 stop food-app 2>/dev/null || true
pm2 delete food-app 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save
DEPLOY_STEP_4

echo "✅ PM2 configured"
echo ""

# Step 5: Configure Nginx
echo "🌐 Step 5: Configuring Nginx..."
ssh -i $KEY_FILE -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'DEPLOY_STEP_5'
sudo tee /etc/nginx/sites-available/food-app > /dev/null << 'NGINX_CONFIG'
server {
    listen 80;
    server_name _;
    client_max_body_size 20M;

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://localhost:3000;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

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
NGINX_CONFIG

sudo ln -sf /etc/nginx/sites-available/food-app /etc/nginx/sites-enabled/food-app
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
DEPLOY_STEP_5

echo "✅ Nginx configured"
echo ""

echo "============================================"
echo "✅ DEPLOYMENT COMPLETE!"
echo "============================================"
echo ""
echo "🌐 Your app is LIVE at:"
echo "   http://98.91.199.145"
echo ""
echo "📊 Check status:"
echo "   ssh -i ~/.ssh/food-app-key.pem ubuntu@98.91.199.145"
echo "   pm2 status"
echo "   pm2 logs food-app"
echo ""
