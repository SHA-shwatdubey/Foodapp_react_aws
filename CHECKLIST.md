# ✅ AWS Deployment Checklist

## Pre-Deployment Setup

### Local Environment
- [ ] Node.js 18+ installed (`node --version`)
- [ ] npm installed (`npm --version`)
- [ ] Git installed (`git --version`)
- [ ] AWS CLI installed (`aws --version`)
- [ ] Terraform installed (`terraform --version`)
- [ ] Ansible installed (`ansible --version`)

### AWS Account
- [ ] AWS Account created
- [ ] AWS Access Key ID obtained
- [ ] AWS Secret Access Key obtained
- [ ] Region set to **us-east-1**

### Local AWS Setup
```bash
# ✓ Run this command
aws configure
# ✓ Enter: Access Key, Secret Key, Region: us-east-1, Format: json
```

### EC2 Key Pair
```bash
# ✓ Run this command
aws ec2 create-key-pair --key-name food-app-key --region us-east-1 \
    --query 'KeyMaterial' --output text > ~/.ssh/food-app-key.pem
chmod 400 ~/.ssh/food-app-key.pem

# ✓ Verify
ls -l ~/.ssh/food-app-key.pem
# Should show: -r-------- (400)
```

---

## GitHub Setup

### Repository Access
- [ ] GitHub repository cloned locally
- [ ] You have push access to the repository
- [ ] You can access repository Settings

### GitHub Secrets Configuration

Go to: **Repository Settings → Secrets and variables → Actions → New repository secret**

Add these 4 secrets:

#### 1. AWS Access Key ID
```
Name: AWS_ACCESS_KEY_ID
Value: <Your AWS Access Key ID>
```
- [ ] Added and verified

#### 2. AWS Secret Access Key
```
Name: AWS_SECRET_ACCESS_KEY
Value: <Your AWS Secret Access Key>
```
- [ ] Added and verified

#### 3. AWS Key Pair Name
```
Name: AWS_KEY_PAIR_NAME
Value: food-app-key
```
- [ ] Added and verified

#### 4. AWS Private Key
```
Name: AWS_PRIVATE_KEY
Value: <Content of ~/.ssh/food-app-key.pem>
```

**To copy the private key:**
```bash
# macOS
cat ~/.ssh/food-app-key.pem | pbcopy

# Ubuntu/Linux
cat ~/.ssh/food-app-key.pem | xclip -selection clipboard

# Windows PowerShell
Get-Content ~/.ssh/food-app-key.pem | Set-Clipboard
```
- [ ] Added and verified

---

## Project Files Verification

### Terraform Files
- [ ] `terraform/main.tf` exists
- [ ] `terraform/variables.tf` exists
- [ ] `terraform/outputs.tf` exists
- [ ] `terraform/terraform.tfvars` exists
- [ ] `terraform/user_data.sh` exists

### Ansible Files
- [ ] `ansible/playbook.yml` exists
- [ ] `ansible/hosts` exists
- [ ] `ansible/roles/app/tasks/main.yml` exists
- [ ] `ansible/roles/app/templates/nginx.conf.j2` exists
- [ ] `ansible/roles/app/templates/ecosystem.config.js.j2` exists

### GitHub Actions
- [ ] `.github/workflows/deploy.yml` exists

### Scripts
- [ ] `scripts/setup-deployment.sh` exists
- [ ] `scripts/deploy-local.sh` exists
- [ ] `scripts/destroy.sh` exists

### Documentation
- [ ] `README.md` exists
- [ ] `QUICKSTART.md` exists
- [ ] `DEPLOYMENT.md` exists
- [ ] `DEPLOYMENT_SUMMARY.md` exists

---

## Deployment Steps

### Step 1: Verify Local Setup
```bash
# Run this to verify everything
cd terraform
terraform init
terraform validate
```
- [ ] No errors

### Step 2: Commit and Push
```bash
cd react-food-delivery-app
git add .
git commit -m "Add Terraform and Ansible deployment configuration"
git push origin main
```
- [ ] Code pushed successfully
- [ ] No push errors

### Step 3: Monitor GitHub Actions
```
GitHub → Actions → "Deploy to AWS with Terraform & Ansible"
```
- [ ] Workflow triggered
- [ ] Build step completed
- [ ] Terraform step completed
- [ ] Ansible step completed
- [ ] No errors in logs

### Step 4: Get Application URL
```bash
cd terraform
terraform output instance_public_ip
```
- [ ] IP address displayed
- [ ] Note the IP for accessing the app

### Step 5: Verify Application
```bash
# Open in browser
http://<INSTANCE_IP>

# Or curl to verify
curl http://<INSTANCE_IP>
```
- [ ] Application loads successfully
- [ ] No connection errors

---

## Post-Deployment Verification

### SSH Access
```bash
ssh -i ~/.ssh/food-app-key.pem ubuntu@<INSTANCE_IP>
```
- [ ] SSH connection successful
- [ ] Logged into EC2 instance

### Application Status
```bash
# While SSH'd into instance
pm2 status
```
- [ ] App is running
- [ ] Status shows "online"

### Application Logs
```bash
pm2 logs food-app
```
- [ ] No error messages
- [ ] App is accepting requests

### Nginx Status
```bash
sudo systemctl status nginx
```
- [ ] Nginx is active (running)
- [ ] No errors

---

## Production Hardening (Optional)

### Security Updates
- [ ] SSH CIDR restricted to your IP in `terraform/terraform.tfvars`
- [ ] SSH password login disabled
- [ ] Firewall configured

### HTTPS Setup
- [ ] AWS Certificate Manager SSL certificate created
- [ ] Nginx HTTPS enabled
- [ ] Redirect HTTP to HTTPS

### Environment Variables
- [ ] Sensitive data stored in GitHub Secrets
- [ ] Never committed to repository
- [ ] Accessed via environment variables

### Backups
- [ ] Code backed up to GitHub
- [ ] Database backups configured (if applicable)

---

## Troubleshooting Checklist

If deployment fails:

### GitHub Actions Failed
- [ ] Check "Deploy to AWS with Terraform & Ansible" logs
- [ ] Verify AWS credentials in GitHub Secrets
- [ ] Check AWS CLI is configured correctly locally

### Terraform Failed
- [ ] Verify AWS credentials have sufficient permissions
- [ ] Check AWS region is us-east-1
- [ ] Verify EC2 key pair exists in AWS
- [ ] Check terraform syntax: `terraform validate`

### Ansible Failed
- [ ] Verify EC2 instance is running in AWS console
- [ ] Check security group allows SSH (port 22)
- [ ] Verify private key has correct permissions (400)
- [ ] Check instance is fully initialized (wait 30-60 seconds)

### Application Not Loading
- [ ] Check EC2 instance status in AWS console
- [ ] Verify security group allows port 80
- [ ] SSH into instance and check PM2 logs
- [ ] Check Nginx status and logs
- [ ] Verify Elastic IP is assigned to instance

---

## Cleanup (When Done Testing)

```bash
# Destroy all AWS resources
cd terraform
terraform destroy -auto-approve

# Or use the script
chmod +x scripts/destroy.sh
./scripts/destroy.sh
```
- [ ] Resources destroyed successfully
- [ ] No pending resources in AWS

---

## Next Deployments

For subsequent deployments:

```bash
# Make code changes
# Push to GitHub
git add .
git commit -m "Your changes"
git push origin main

# GitHub Actions will automatically:
# 1. Build React app
# 2. Update EC2 instance
# 3. Redeploy application
```
- [ ] Workflow triggered automatically
- [ ] App redeployed successfully

---

## Support Resources

- 📖 **Full Guide:** `DEPLOYMENT.md`
- 🚀 **Quick Start:** `QUICKSTART.md`
- 📋 **Summary:** `DEPLOYMENT_SUMMARY.md`
- 🏠 **Project:** `README.md`

---

## Completion Status

**Pre-Deployment:** [ ] Completed

**Deployment:** [ ] Completed

**Verification:** [ ] Completed

**Hardening:** [ ] Completed (Optional)

**Ready for Production:** [ ] Yes / [ ] No

---

**Last Updated:** 2025-11-10

**Status:** ✅ Ready to Deploy

---

**🎉 Congratulations! You're all set to deploy your React app on AWS!**
