# Quick Start Guide 🚀

## 5 मिनट में AWS पर Deploy करें

### Step 1: AWS Credentials Setup करें
```bash
aws configure
# अपनी AWS Access Key ID डालें
# अपनी AWS Secret Access Key डालें
# Region: us-east-1
# Format: json
```

### Step 2: EC2 Key Pair बनाएं
```bash
aws ec2 create-key-pair --key-name food-app-key --region us-east-1 \
    --query 'KeyMaterial' --output text > ~/.ssh/food-app-key.pem
chmod 400 ~/.ssh/food-app-key.pem
```

### Step 3: GitHub Secrets सेट करें

अपने GitHub repository में:
1. **Settings** → **Secrets and variables** → **Actions**
2. ये secrets add करें:

```
AWS_ACCESS_KEY_ID         = <आपकी AWS access key>
AWS_SECRET_ACCESS_KEY     = <आपकी AWS secret key>
AWS_KEY_PAIR_NAME         = food-app-key
AWS_PRIVATE_KEY           = <~/.ssh/food-app-key.pem की content>
```

### Step 4: Push करें
```bash
git add .
git commit -m "Add deployment configs"
git push origin main
```

### Step 5: GitHub Actions देखें
1. GitHub repository में **Actions** tab खोलें
2. **Deploy to AWS with Terraform & Ansible** workflow देखें
3. Deployment complete होने तक wait करें (10-15 minutes)

### Step 6: Application खोलें
```bash
cd terraform
terraform output instance_public_ip
# Output: X.X.X.X

# Browser में खोलें:
# http://X.X.X.X
```

---

## Local Deployment (बिना GitHub के)

```bash
# Setup करें
chmod +x scripts/setup-deployment.sh
./scripts/setup-deployment.sh

# Deploy करें
chmod +x scripts/deploy-local.sh
./scripts/deploy-local.sh
```

---

## Resources Destroy करें

```bash
cd terraform
terraform destroy -auto-approve
```

---

**✅ Done! आपका React app अब AWS पर live है!**
