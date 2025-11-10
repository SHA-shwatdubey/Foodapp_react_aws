#!/bin/bash
set -e

INSTANCE_IP="98.94.91.124"
KEY_FILE="~/.ssh/food-app-key.pem"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           🚀 DEPLOYING REACT APP TO EC2                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "📦 Step 1: Cloning repository..."
ssh -i ~/.ssh/food-app-key.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'EOF'
cd /var/www
sudo rm -rf food-app
sudo mkdir -p food-app
sudo chown ubuntu:ubuntu food-app
cd food-app
git clone https://github.com/SHA-shwatdubey/Foodapp_react_aws.git .
EOF
echo "✅ Repository cloned"

echo ""
echo "📥 Step 2: Installing dependencies..."
ssh -i ~/.ssh/food-app-key.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'EOF'
cd /var/www/food-app/food-app
npm install
EOF
echo "✅ Dependencies installed"

echo ""
echo "🏗️  Step 3: Building React app..."
ssh -i ~/.ssh/food-app-key.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'EOF'
cd /var/www/food-app/food-app
npm run build
EOF
echo "✅ React app built"

echo ""
echo "⚙️  Step 4: Configuring PM2..."
ssh -i ~/.ssh/food-app-key.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'EOF'
mkdir -p /var/log/pm2
cd /var/www/food-app

cat > ecosystem.config.js << 'ECOCONFIG'
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
    out_file: '/var/log/pm2/food-app-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
  }]
};
ECOCONFIG

pm2 stop food-app || true
pm2 delete food-app || true
pm2 start ecosystem.config.js
pm2 save
EOF
echo "✅ PM2 configured"

echo ""
echo "🌐 Step 5: Configuring Nginx..."
ssh -i ~/.ssh/food-app-key.pem -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'EOF'
sudo tee /etc/nginx/sites-available/food-app > /dev/null << 'NGINXCONFIG'
server {
    listen 80;
    server_name _;
    client_max_body_size 20M;
    gzip on;
    gzip_types text/css application/javascript application/json;

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
NGINXCONFIG

sudo ln -sf /etc/nginx/sites-available/food-app /etc/nginx/sites-enabled/food-app
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
EOF
echo "✅ Nginx configured"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           ✅ DEPLOYMENT COMPLETE!                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Your app is now live at:"
echo "   http://$INSTANCE_IP"
echo ""
echo "📊 Check Status:"
echo "   ssh -i ~/.ssh/food-app-key.pem ubuntu@$INSTANCE_IP"
echo "   pm2 status"
echo "   pm2 logs food-app"
echo ""
echo "🔄 Redeploy (when making changes):"
echo "   bash redeploy.sh"
echo ""
