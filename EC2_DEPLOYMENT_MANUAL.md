# 🚀 AWS EC2 Deployment - SUCCESS!

## ✅ Instance Created

Your EC2 instance is now running on AWS!

**Instance Details:**
```
Instance ID: i-0ce5e842edd34e18a
Public IP: 98.94.91.124
Region: us-east-1
Instance Type: t2.micro
OS: Ubuntu 22.04 LTS
```

---

## 🔑 SSH Access

```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124
```

---

## 📦 Deploy Your React App

### Step 1: Clone Repository on EC2

```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124 << 'EOF'
cd /var/www/food-app
git clone https://github.com/SHA-shwatdubey/Foodapp_react_aws.git .
EOF
```

### Step 2: Install Dependencies & Build

```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124 << 'EOF'
cd /var/www/food-app/food-app
npm install
npm run build
EOF
```

### Step 3: Start with PM2

```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124 << 'EOF'
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

mkdir -p /var/log/pm2
pm2 start ecosystem.config.js
pm2 save
EOF
```

### Step 4: Configure Nginx

```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124 << 'EOF'
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
```

---

## 🌐 Access Your App

After completing all steps, your app will be available at:
```
http://98.94.91.124
```

---

## 📊 Check Status

```bash
# SSH into instance
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124

# Check PM2 status
pm2 status

# Check logs
pm2 logs food-app

# Check Nginx status
sudo systemctl status nginx
```

---

## 🔄 Redeploy (When You Make Changes)

```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124 << 'EOF'
cd /var/www/food-app
git pull origin main
cd food-app
npm install
npm run build
cd ..
pm2 restart food-app
EOF
```

---

## ❌ Troubleshooting

### If npm is not installed
```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124 << 'EOF'
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
sudo apt-get install -y nodejs
npm install -g pm2
EOF
```

### If Nginx not responding
```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124 << 'EOF'
sudo systemctl restart nginx
sudo systemctl status nginx
EOF
```

### Check user data logs
```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124 'cat /var/log/user-data.log'
```

---

## 💾 Terminate Instance (When Done)

```bash
aws ec2 terminate-instances --instance-ids i-0ce5e842edd34e18a --region us-east-1
```

---

**Created:** November 10, 2025
**Instance IP:** 98.94.91.124
