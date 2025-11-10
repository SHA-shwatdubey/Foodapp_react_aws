#!/bin/bash

# Local deployment script (without GitHub Actions)
# Run Terraform and Ansible locally

set -e

AWS_REGION="us-east-1"
PROJECT_NAME="food-app"

echo "🚀 Starting local deployment..."

# Check prerequisites
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    exit 1
fi

if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed"
    exit 1
fi

# Build React app
echo "🔨 Building React application..."
cd food-app
npm install
npm run build
cd ..
echo "✅ Build complete!"

# Initialize and apply Terraform
echo "📦 Setting up AWS infrastructure..."
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Get the instance IP
INSTANCE_IP=$(terraform output -raw instance_public_ip)
echo "✅ Infrastructure deployed! Instance IP: $INSTANCE_IP"

cd ..

# Wait for instance to be ready
echo "⏳ Waiting for instance to be ready..."
sleep 30

# Update Ansible inventory
echo "📝 Updating Ansible inventory..."
cat > ansible/hosts << EOF
[webservers]
$INSTANCE_IP ansible_user=ubuntu ansible_private_key_file=~/.ssh/food-app-key.pem

[webservers:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

# Run Ansible playbook
echo "🚀 Deploying application with Ansible..."
cd ansible
ansible-playbook -i hosts playbook.yml \
    -e "github_repo_url=https://github.com/codes4education/react-food-delivery-app.git" \
    -e "github_branch=main" \
    -v
cd ..

echo ""
echo "✅ Deployment complete!"
echo "🌐 Application is running at: http://$INSTANCE_IP"
echo ""
echo "SSH into the instance:"
echo "ssh -i ~/.ssh/food-app-key.pem ubuntu@$INSTANCE_IP"
