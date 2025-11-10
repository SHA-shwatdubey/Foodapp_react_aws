# 🚀 AWS EC2 Deployment - Manual Steps

## ✅ What's Already Done

- ✅ React app ready locally at `localhost:3000`
- ✅ AWS EC2 instance created: **98.94.91.124**
- ✅ Terraform & Ansible files ready
- ✅ GitHub repository configured

---

## 🎯 Deploy Your React App in 5 Simple Steps

### Step 1: SSH into EC2 Instance
```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@98.94.91.124
```

### Step 2: Install Node.js & Tools
```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs git nginx

# Install PM2 globally
sudo npm install -g pm2
```

### Step 3: Clone & Build Your App
```bash
# Create directory
sudo mkdir -p /var/www/food-app
sudo chown -R ubuntu:ubuntu /var/www/food-app
cd /var/www/food-app

# Clone your repo
git clone https://github.com/SHA-shwatdubey/Foodapp_react_aws.git .
cd food-app

# Install dependencies
npm install

# Build for production
npm run build
```

### Step 4: Setup PM2 & Start App
```bash
# Go to app root
cd /var/www/food-app

# Create ecosystem.config.js
cat > ecosystem.config.js << 'EOF'
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
EOF

# Start app
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Step 5: Configure Nginx Reverse Proxy
```bash
# Create Nginx config
sudo tee /etc/nginx/sites-available/food-app > /dev/null << 'EOF'
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
EOF

# Enable Nginx config
sudo ln -sf /etc/nginx/sites-available/food-app /etc/nginx/sites-enabled/food-app
sudo rm -f /etc/nginx/sites-enabled/default

# Test and restart
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

---

## 🎉 Done! Your App is Live!

After completing all 5 steps, your React app will be available at:

👉 **http://98.94.91.124**

---

## 📱 Useful Commands

| Command | Purpose |
|---------|---------|
| `pm2 status` | Check app status |
| `pm2 logs` | View app logs |
| `pm2 restart food-app` | Restart app |
| `pm2 stop food-app` | Stop app |
| `sudo systemctl restart nginx` | Restart Nginx |
| `curl http://localhost:3000` | Test locally |

---

## 🔧 Troubleshooting

If app is not loading:
1. Check PM2 status: `pm2 status`
2. View PM2 logs: `pm2 logs food-app`
3. Check Nginx: `sudo nginx -t`
4. Restart services: `pm2 restart food-app && sudo systemctl restart nginx`

---

## 📊 Instance Details

- **Instance IP:** 98.94.91.124
- **Instance ID:** i-0ce5e842edd34e18a
- **Region:** us-east-1
- **Type:** t2.micro (Free tier)
- **OS:** Ubuntu 22.04 LTS

---

## ⏹️ To Stop Everything

```bash
# Stop app
pm2 stop food-app

# Stop Nginx
sudo systemctl stop nginx

# Terminate instance (from AWS Console or CLI)
aws ec2 terminate-instances --instance-ids i-0ce5e842edd34e18a --region us-east-1
```
