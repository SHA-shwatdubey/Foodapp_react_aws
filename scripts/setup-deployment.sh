#!/bin/bash

# Setup local deployment environment
# This script helps prepare AWS credentials and local tools

set -e

echo "🚀 Setting up Food App deployment environment..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first:"
    echo "   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first:"
    echo "   https://www.terraform.io/downloads.html"
    exit 1
fi

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed. Please install it first:"
    echo "   https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html"
    exit 1
fi

echo "✅ All required tools are installed!"

# Configure AWS credentials
echo ""
echo "📝 Configuring AWS credentials..."
read -p "Enter your AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -sp "Enter your AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo ""

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region us-east-1

echo "✅ AWS credentials configured!"

# Create EC2 Key Pair
echo ""
echo "🔑 Setting up EC2 Key Pair..."
read -p "Enter EC2 Key Pair name (default: food-app-key): " KEY_PAIR_NAME
KEY_PAIR_NAME=${KEY_PAIR_NAME:-food-app-key}

if aws ec2 describe-key-pairs --key-names "$KEY_PAIR_NAME" --region us-east-1 &> /dev/null; then
    echo "✅ Key pair '$KEY_PAIR_NAME' already exists in AWS"
else
    echo "Creating new key pair: $KEY_PAIR_NAME"
    aws ec2 create-key-pair --key-name "$KEY_PAIR_NAME" --region us-east-1 --query 'KeyMaterial' --output text > ~/.ssh/"$KEY_PAIR_NAME".pem
    chmod 400 ~/.ssh/"$KEY_PAIR_NAME".pem
    echo "✅ Key pair created and saved to ~/.ssh/$KEY_PAIR_NAME.pem"
fi

# Update Terraform variables
echo ""
echo "⚙️  Updating Terraform configuration..."
sed -i "s/key_pair_name    = .*/key_pair_name    = \"$KEY_PAIR_NAME\"/" terraform/terraform.tfvars
echo "✅ Terraform configuration updated!"

# Test Terraform
echo ""
echo "🧪 Testing Terraform configuration..."
cd terraform
terraform init
terraform validate
cd ..
echo "✅ Terraform configuration is valid!"

echo ""
echo "✅ Environment setup complete!"
echo ""
echo "📚 Next steps:"
echo "1. Add your GitHub Secrets (see DEPLOYMENT.md for details)"
echo "2. Push your code to GitHub"
echo "3. The deployment will start automatically via GitHub Actions"
echo ""
