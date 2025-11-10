# 🍔 React Food Delivery App

> A modern food delivery application built with React, deployed on AWS using Terraform and Ansible with GitHub Actions CI/CD

[![Deploy to AWS with Terraform & Ansible](https://github.com/codes4education/react-food-delivery-app/actions/workflows/deploy.yml/badge.svg)](https://github.com/codes4education/react-food-delivery-app/actions)

## 🌟 Features

- ✨ **Modern React UI** - Built with React 18 and Bootstrap
- 📱 **Responsive Design** - Works on all devices
- 🚀 **One-Click Deploy** - Automated deployment to AWS
- 🔒 **Secure** - Using Terraform and Ansible for infrastructure
- 💰 **Free Tier Eligible** - Deploy for free on AWS Free Tier
- 🔄 **CI/CD Pipeline** - Automatic deployment on every push
- 📊 **Production Ready** - With Nginx reverse proxy and PM2 process manager

## 🏗️ Architecture

```
GitHub (Source Code)
    ↓
GitHub Actions (CI/CD)
    ├─ Build React App
    ├─ Deploy Infrastructure (Terraform)
    └─ Deploy Application (Ansible)
    ↓
AWS (us-east-1)
    └─ EC2 Instance (t2.micro) + Nginx + PM2
```

## 📋 Prerequisites

### Local Development
- Node.js 18+
- npm or yarn
- Git

### For AWS Deployment
- AWS Account (Free Tier eligible)
- AWS CLI
- Terraform 1.0+
- Ansible 2.10+

## 🚀 Quick Start

### 1. Local Development

```bash
# Clone the repository
git clone https://github.com/codes4education/react-food-delivery-app.git
cd react-food-delivery-app/food-app

# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build
```

### 2. Deploy to AWS (GitHub Actions)

**Step 1: Setup AWS**
```bash
aws configure
# Enter your AWS credentials and set region to us-east-1
```

**Step 2: Create EC2 Key Pair**
```bash
aws ec2 create-key-pair --key-name food-app-key --region us-east-1 \
    --query 'KeyMaterial' --output text > ~/.ssh/food-app-key.pem
chmod 400 ~/.ssh/food-app-key.pem
```

**Step 3: Add GitHub Secrets**

Go to: Repository Settings → Secrets and variables → Actions

Add these secrets:
- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret key
- `AWS_KEY_PAIR_NAME` - `food-app-key`
- `AWS_PRIVATE_KEY` - Content of `~/.ssh/food-app-key.pem`

**Step 4: Push and Deploy**
```bash
git add .
git commit -m "Deploy to AWS"
git push origin main
```

**Step 5: Watch Deployment**
- Go to GitHub → Actions
- Watch the "Deploy to AWS with Terraform & Ansible" workflow
- Once complete, your app will be live!

### 3. Local Deployment (Without GitHub)

```bash
# Setup deployment environment
chmod +x scripts/setup-deployment.sh
./scripts/setup-deployment.sh

# Deploy locally
chmod +x scripts/deploy-local.sh
./scripts/deploy-local.sh
```

## 📚 Documentation

- **[QUICKSTART.md](./QUICKSTART.md)** - 5-minute quick start guide
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Complete deployment guide with troubleshooting
- **[DEPLOYMENT_SUMMARY.md](./DEPLOYMENT_SUMMARY.md)** - Comprehensive overview of the setup

## 📁 Project Structure

```
react-food-delivery-app/
├── food-app/                    # React application
│   ├── src/
│   │   ├── components/          # React components
│   │   ├── pages/              # Page components
│   │   ├── styles/             # CSS stylesheets
│   │   └── App.js              # Main app component
│   ├── package.json
│   └── README.md
│
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # AWS resources
│   ├── variables.tf            # Variables definition
│   ├── outputs.tf              # Output values
│   ├── terraform.tfvars        # Configuration values
│   └── user_data.sh            # EC2 initialization
│
├── ansible/                     # Configuration Management
│   ├── playbook.yml            # Main playbook
│   ├── hosts                   # Inventory
│   └── roles/app/              # App deployment role
│       ├── tasks/              # Deployment tasks
│       └── templates/          # Config templates
│
├── scripts/                     # Helper scripts
│   ├── setup-deployment.sh     # Setup environment
│   ├── deploy-local.sh         # Local deployment
│   └── destroy.sh              # Cleanup resources
│
├── .github/workflows/          # GitHub Actions
│   └── deploy.yml              # CI/CD pipeline
│
├── DEPLOYMENT.md               # Full deployment guide
├── QUICKSTART.md               # Quick start guide
└── DEPLOYMENT_SUMMARY.md       # Setup summary
```

## 🛠️ Technology Stack

| Component | Technology |
|-----------|-----------|
| **Frontend** | React 18 |
| **Package Manager** | npm |
| **CSS** | Bootstrap 5 |
| **Build Tool** | Create React App |
| **Node Runtime** | Node.js 18 |
| **Process Manager** | PM2 |
| **Web Server** | Nginx |
| **Infrastructure** | Terraform |
| **Configuration** | Ansible |
| **CI/CD** | GitHub Actions |
| **Cloud** | AWS (us-east-1) |

## 🌐 Accessing Your App

After deployment, your app will be accessible at:

```
http://<INSTANCE_IP>
```

Get the IP address:
```bash
cd terraform
terraform output instance_public_ip
```

Or from GitHub Actions logs - look for "Application URL"

## 💰 Cost Estimation

**AWS Free Tier (First 12 months):** $0/month
- t2.micro: 750 hours free per month
- 1 GB data transfer free per month

**After Free Tier:** ~$10-15/month
- t2.micro: ~$8-10/month
- Data transfer and other services: ~$2-5/month

## 🔐 Security

### Production Recommendations

1. **Restrict SSH Access**
   - Edit `terraform/terraform.tfvars`
   - Change `ssh_allowed_cidr` from `["0.0.0.0/0"]` to `["YOUR_IP/32"]`

2. **Enable HTTPS**
   - Use AWS Certificate Manager for free SSL certificates
   - Update Nginx configuration

3. **Environment Variables**
   - Store sensitive data in GitHub Secrets
   - Use them in the workflow

4. **Key Management**
   - Never commit private keys
   - Store `~/.ssh/food-app-key.pem` safely
   - Rotate keys periodically

## 📊 Monitoring

SSH into your instance:
```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@<INSTANCE_IP>

# Check app status
pm2 status

# View app logs
pm2 logs food-app

# Check system resources
free -h
df -h

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
```

## 🗑️ Cleanup

To destroy all AWS resources:

```bash
cd terraform
terraform destroy -auto-approve
```

Or use the cleanup script:
```bash
chmod +x scripts/destroy.sh
./scripts/destroy.sh
```

## 🐛 Troubleshooting

### SSH Connection Issues
```bash
# Verify key permissions
ls -l ~/.ssh/food-app-key.pem

# Should output: -r-------- (400)
```

### Deployment Failures
1. Check GitHub Actions logs
2. Verify AWS credentials in GitHub Secrets
3. Ensure EC2 key pair exists in AWS

### App Not Loading
1. Check if EC2 instance is running
2. Verify security group allows port 80 and 443
3. SSH into instance and check PM2 logs

See **[DEPLOYMENT.md](./DEPLOYMENT.md)** for more troubleshooting

## 📞 Support

- 📖 Read the [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed guide
- 🔍 Check [Troubleshooting section](./DEPLOYMENT.md#-troubleshooting)
- 🐛 Open a GitHub issue for bugs
- 💡 Create a discussion for questions

## 📝 License

This project is licensed under the MIT License.

## 🙏 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 👥 Authors

- **codes4education** - Project setup and infrastructure

---

## 🚀 Next Steps

1. ✅ Read [QUICKSTART.md](./QUICKSTART.md) for a 5-minute setup
2. ✅ Follow [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed instructions
3. ✅ Deploy your app
4. ✅ Share your experience!

---

**Made with ❤️ by codes4education**

**Happy Deploying! 🎉**
