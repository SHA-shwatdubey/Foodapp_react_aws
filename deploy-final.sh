#!/bin/bash
set -e

INSTANCE_IP="13.218.237.9"
KEY_FILE="$HOME/.ssh/food-app-key.pem"
REPO_URL="https://github.com/SHA-shwatdubey/Foodapp_react_aws.git"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        🚀 DEPLOYING REACT APP TO AWS EC2                   ║"
echo "║           Instance: $INSTANCE_IP                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Function to SSH into instance
ssh_exec() {
  ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@$INSTANCE_IP "$@"
}

echo "⏳ Step 1: Waiting for instance to be ready..."
for i in {1..60}; do
  if ssh_exec "echo 'ready'" 2>/dev/null; then
    echo "✅ Instance is ready!"
    break
  fi
  echo "   Attempt $i/60..."
  sleep 5
done

echo ""
echo "📦 Step 2: Cloning repository..."
ssh_exec << 'EOF'
cd /var/www
sudo rm -rf food-app 2>/dev/null || true
sudo mkdir -p food-app
sudo chown -R ubuntu:ubuntu food-app
cd food-app
git clone https://github.com/SHA-shwatdubey/Foodapp_react_aws.git .
EOF
echo "✅ Repository cloned"

echo ""
echo "📥 Step 3: Installing dependencies..."
ssh_exec << 'EOF'
cd /var/www/food-app/food-app
npm install
EOF
echo "✅ Dependencies installed"

echo ""
echo "🏗️  Step 4: Building React app..."
ssh_exec << 'EOF'
cd /var/www/food-app/food-app
npm run build
EOF
echo "✅ React app built successfully"

echo ""
echo "⚙️  Step 5: Configuring PM2..."
ssh_exec << 'EOF'
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

pm2 stop food-app 2>/dev/null || true
pm2 delete food-app 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save
EOF
echo "✅ PM2 configured and app started"

echo ""
echo "🌐 Step 6: Configuring Nginx..."
ssh_exec << 'EOF'
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
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           ✅ DEPLOYMENT COMPLETE!                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Your app is NOW LIVE at:"
echo "   👉 http://13.218.237.9"
echo ""
echo "📊 Check Status:"
echo "   ssh -i ~/.ssh/food-app-key.pem ubuntu@13.218.237.9"
echo "   pm2 status"
echo "   pm2 logs food-app -f"
echo ""
echo "🔄 Redeploy (when making code changes):"
echo "   cd /var/www/food-app"
echo "   git pull origin main"
echo "   cd food-app && npm run build"
echo "   pm2 restart food-app"
echo ""
