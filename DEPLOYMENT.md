# AWS Deployment Guide - React Food Delivery App

यह guide आपको AWS पर React app को Terraform और Ansible के साथ deploy करने में मदद करेगा।

## 📋 Prerequisites

### Local Tools
```bash
# AWS CLI
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

# Terraform (v1.0+)
https://www.terraform.io/downloads.html

# Ansible (v2.10+)
https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

# Node.js (v18+)
https://nodejs.org/

# Git
https://git-scm.com/
```

### AWS Account
- एक AWS account की जरूरत है (Free Tier eligible है)
- AWS Access Key ID और Secret Access Key

---

## 🔧 Step 1: Local Setup

### 1.1 Tools Install करें

**macOS (Homebrew के साथ):**
```bash
brew install terraform ansible awscli nodejs
```

**Ubuntu/Debian:**
```bash
# Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Ansible
sudo apt-get update
sudo apt-get install -y ansible

# AWS CLI
sudo apt-get install -y awscli

# Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Windows (chocolatey के साथ):**
```powershell
choco install terraform ansible awscli nodejs -y
```

### 1.2 AWS Credentials Setup

```bash
aws configure
# अपनी credentials enter करें:
# - AWS Access Key ID: [आपकी key]
# - AWS Secret Access Key: [आपकी secret key]
# - Default region: us-east-1
# - Default output format: json
```

### 1.3 EC2 Key Pair Create करें

```bash
# AWS में key pair बनाएं
aws ec2 create-key-pair --key-name food-app-key --region us-east-1 \
    --query 'KeyMaterial' --output text > ~/.ssh/food-app-key.pem

# Permissions set करें
chmod 400 ~/.ssh/food-app-key.pem
```

---

## 🚀 Step 2: GitHub Actions के साथ Deploy करें (Recommended)

### 2.1 GitHub Secrets Setup करें

अपने GitHub repository में जाएं:
1. **Settings** → **Secrets and variables** → **Actions**
2. निम्नलिखित secrets add करें:

```
AWS_ACCESS_KEY_ID            = आपकी AWS access key
AWS_SECRET_ACCESS_KEY        = आपकी AWS secret key
AWS_KEY_PAIR_NAME            = food-app-key
AWS_PRIVATE_KEY              = ~/.ssh/food-app-key.pem की content
```

**Private Key को कैसे copy करें:**
```bash
# macOS/Linux
cat ~/.ssh/food-app-key.pem | pbcopy

# Ubuntu
cat ~/.ssh/food-app-key.pem | xclip -selection clipboard

# Windows (PowerShell)
Get-Content ~/.ssh/food-app-key.pem | Set-Clipboard
```

### 2.2 Code Push करें

```bash
# Repo में जाएं
cd react-food-delivery-app

# Changes commit करें
git add .
git commit -m "Add Terraform and Ansible deployment configs"

# GitHub को push करें
git push origin main
```

### 2.3 Deployment Status देखें

GitHub repository में:
1. **Actions** tab पर जाएं
2. **Deploy to AWS with Terraform & Ansible** workflow देखें
3. Deployment complete होने तक wait करें (10-15 minutes)
4. Output में application URL देखें

---

## 💻 Local Deployment (बिना GitHub Actions के)

अगर आप locally deploy करना चाहते हैं:

### 2.1 Setup Script चलाएं

```bash
chmod +x scripts/setup-deployment.sh
./scripts/setup-deployment.sh
```

यह script:
- AWS credentials verify करेगा
- EC2 key pair create करेगा
- Terraform validate करेगा

### 2.2 Local Deploy करें

```bash
chmod +x scripts/deploy-local.sh
./scripts/deploy-local.sh
```

यह script:
- React app build करेगा
- Terraform apply करेगा (infrastructure बनाएगा)
- Ansible चलाएगा (app deploy करेगा)
- Application URL print करेगा

---

## 🌐 Application Access करें

Deployment के बाद, आपका app यहाँ available होगा:

```
http://<INSTANCE_IP>
```

Instance IP को यहाँ से get करें:

**GitHub Actions से:**
1. Workflow logs में search करें: "Application URL"

**Local deployment से:**
```bash
cd terraform
terraform output instance_public_ip
```

---

## 📊 Infrastructure Architecture

```
┌─────────────────────────────────────────────────────┐
│                    AWS us-east-1                    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌────────────────────────────────────────────┐    │
│  │           VPC (10.0.0.0/16)               │    │
│  │                                             │    │
│  │  ┌──────────────────────────────────────┐ │    │
│  │  │   Public Subnet (10.0.1.0/24)       │ │    │
│  │  │                                      │ │    │
│  │  │  ┌────────────────────────────────┐ │ │    │
│  │  │  │  EC2 Instance (t2.micro)      │ │ │    │
│  │  │  │  - Ubuntu 22.04 LTS           │ │ │    │
│  │  │  │  - Node.js 18                 │ │ │    │
│  │  │  │  - Nginx (Reverse Proxy)      │ │ │    │
│  │  │  │  - PM2 (Process Manager)      │ │ │    │
│  │  │  │  - React App                  │ │ │    │
│  │  │  └────────────────────────────────┘ │ │    │
│  │  │                                      │ │    │
│  │  │  Elastic IP: <PUBLIC_IP>            │ │    │
│  │  └──────────────────────────────────────┘ │    │
│  │                                             │    │
│  └────────────────────────────────────────────┘    │
│                                                     │
│  Internet Gateway                                  │
└─────────────────────────────────────────────────────┘
```

---

## 🔐 Security Groups

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | 0.0.0.0/0 | SSH (Change to your IP in production) |
| 80 | TCP | 0.0.0.0/0 | HTTP |
| 443 | TCP | 0.0.0.0/0 | HTTPS (अभी configured नहीं है) |
| 3000 | TCP | 0.0.0.0/0 | React App (PM2 backend) |

**Production के लिए Security update:**

`terraform/terraform.tfvars` में:
```hcl
ssh_allowed_cidr = ["YOUR_IP/32"]  # अपना IP लगाएं
```

---

## 📝 Configuration Files

### Terraform Files

| File | Purpose |
|------|---------|
| `main.tf` | AWS resources (VPC, EC2, SG) |
| `variables.tf` | Variable definitions |
| `outputs.tf` | Output values (IP, URLs) |
| `terraform.tfvars` | Variable values |
| `user_data.sh` | EC2 initialization script |

### Ansible Files

| File | Purpose |
|------|---------|
| `playbook.yml` | Main playbook |
| `hosts` | Inventory file |
| `roles/app/tasks/main.yml` | Deployment tasks |
| `roles/app/templates/nginx.conf.j2` | Nginx config |
| `roles/app/templates/ecosystem.config.js.j2` | PM2 config |

### GitHub Actions

| File | Purpose |
|------|---------|
| `.github/workflows/deploy.yml` | CI/CD pipeline |

---

## 🔄 Deployment Workflow

```
GitHub Push (main branch)
    ↓
GitHub Actions Triggered
    ├─ Build: React app compile
    │
    ├─ Terraform: Infrastructure setup
    │  ├─ Create VPC
    │  ├─ Create Subnet
    │  ├─ Create Security Group
    │  └─ Create EC2 Instance
    │
    └─ Ansible: Application deployment
       ├─ Clone repository
       ├─ Install dependencies
       ├─ Build React app
       ├─ Setup PM2
       ├─ Configure Nginx
       └─ Start application
    ↓
Application Live ✅
```

---

## 🛠️ Common Commands

### Terraform Commands

```bash
cd terraform

# Initialize
terraform init

# Validate
terraform validate

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy
terraform destroy

# Get output
terraform output instance_public_ip
```

### Ansible Commands

```bash
cd ansible

# Syntax check
ansible-playbook -i hosts playbook.yml --syntax-check

# Dry run
ansible-playbook -i hosts playbook.yml --check

# Run
ansible-playbook -i hosts playbook.yml \
    -e "github_repo_url=<REPO_URL>" \
    -e "github_branch=main"

# Debug mode
ansible-playbook -i hosts playbook.yml -vvv
```

### SSH में EC2 में जाएं

```bash
# Instance IP के साथ
ssh -i ~/.ssh/food-app-key.pem ubuntu@<INSTANCE_IP>

# या Terraform output से
INSTANCE_IP=$(cd terraform && terraform output -raw instance_public_ip)
ssh -i ~/.ssh/food-app-key.pem ubuntu@$INSTANCE_IP
```

---

## 📊 Monitoring

EC2 में लॉगिन करें:

```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@<INSTANCE_IP>

# PM2 status
pm2 status
pm2 logs food-app

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# System resources
free -h
df -h
```

---

## 🗑️ Cleanup

Resources को destroy करने के लिए:

### GitHub Actions से:

```bash
cd terraform
terraform destroy -auto-approve
```

### Local से:

```bash
chmod +x scripts/destroy.sh
./scripts/destroy.sh
```

**Or manually:**

```bash
cd terraform
terraform destroy
```

---

## 🐛 Troubleshooting

### EC2 में SSH connect नहीं हो रहा है

```bash
# Key permissions check करें
ls -l ~/.ssh/food-app-key.pem
# -r-------- (400) होना चाहिए

# Key recreate करें
aws ec2 delete-key-pair --key-name food-app-key --region us-east-1
aws ec2 create-key-pair --key-name food-app-key --region us-east-1 \
    --query 'KeyMaterial' --output text > ~/.ssh/food-app-key.pem
chmod 400 ~/.ssh/food-app-key.pem
```

### Ansible connection timeout

```bash
# Instance fully ready होने तक wait करें
sleep 60

# फिर से try करें
ansible-playbook -i hosts playbook.yml -vvv
```

### PM2 app नहीं चल रहा है

EC2 में:
```bash
pm2 logs food-app
# Error देखें

# Restart करें
pm2 restart food-app

# या manually start करें
cd /var/www/food-app
pm2 start ecosystem.config.js
```

### Nginx 502 Bad Gateway error

EC2 में:
```bash
# Nginx logs देखें
sudo tail -f /var/log/nginx/error.log

# Nginx test करें
sudo nginx -t

# PM2 app running है check करें
pm2 status

# Restart करें
sudo systemctl restart nginx
pm2 restart food-app
```

---

## 💰 Cost Estimation

**AWS Free Tier के साथ (प्रथम 12 महीने):**
- t2.micro EC2: Free (750 hours/month)
- Data Transfer: Free (1 GB/month)
- **Total Cost: $0/month**

**Free Tier के बाद:**
- t2.micro EC2: ~$8-10/month
- Data Transfer: Minimal
- **Estimated Cost: $10-15/month**

---

## 📞 Support

Issues के लिए:
1. GitHub Issues open करें
2. AWS CloudWatch logs check करें
3. Local रूप से troubleshoot करें

---

## 📚 Additional Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [React Deployment Guide](https://react.dev/learn/start-a-new-react-project)

---

**Happy Deploying! 🚀**
