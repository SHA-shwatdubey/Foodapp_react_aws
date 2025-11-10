#!/bin/bash
set -e

# Get VPC that has an IGW attached
VPC_WITH_IGW=$(aws ec2 describe-vpcs --region us-east-1 --query 'Vpcs[0].VpcId' --output text)
echo "Using VPC: $VPC_WITH_IGW"

# Get a public subnet
PUBLIC_SUBNET=$(aws ec2 describe-subnets --region us-east-1 --filters "Name=vpc-id,Values=$VPC_WITH_IGW" --query 'Subnets[0].SubnetId' --output text)
echo "Using Subnet: $PUBLIC_SUBNET"

# Get latest Ubuntu 22.04 AMI
AMI_ID=$(aws ec2 describe-images --region us-east-1 --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)
echo "Using AMI: $AMI_ID"

# Create security group
SG_NAME="food-app-sg-$(date +%s)"
SG_ID=$(aws ec2 create-security-group --group-name "$SG_NAME" --description "Security group for Food Delivery App" --vpc-id "$VPC_WITH_IGW" --region us-east-1 --query 'GroupId' --output text)
echo "Created Security Group: $SG_ID"

# Add security group rules
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --region us-east-1 \
  --protocol tcp --port 22 --cidr 0.0.0.0/0 \
  --protocol tcp --port 80 --cidr 0.0.0.0/0 \
  --protocol tcp --port 443 --cidr 0.0.0.0/0 \
  --protocol tcp --port 3000 --cidr 0.0.0.0/0

# Get user data script content
USER_DATA=$(cat << 'USERDATA'
#!/bin/bash
set -e
sleep 15
apt-get update
apt-get upgrade -y
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
npm install -g pm2
apt-get install -y nginx git
mkdir -p /var/www/food-app /var/log/pm2
chown -R ubuntu:ubuntu /var/www/food-app /var/log/pm2
systemctl start nginx
systemctl enable nginx
echo "Setup complete!" > /var/log/user-data.log
USERDATA
)

# Launch EC2 instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t2.micro \
  --key-name food-app-key \
  --security-group-ids "$SG_ID" \
  --subnet-id "$PUBLIC_SUBNET" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=food-app-server}]" \
  --user-data "$(echo "$USER_DATA" | base64 -w 0)" \
  --region us-east-1 \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Created EC2 Instance: $INSTANCE_ID"
echo "Waiting for instance to get public IP..."
sleep 10

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region us-east-1 --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "Instance Public IP: $PUBLIC_IP"

# Create elastic IP and associate
ALLOCATION_ID=$(aws ec2 allocate-address --domain vpc --region us-east-1 --query 'AllocationId' --output text)
echo "Allocated Elastic IP: $ALLOCATION_ID"

sleep 5
ASSOC_ID=$(aws ec2 associate-address --instance-id "$INSTANCE_ID" --allocation-id "$ALLOCATION_ID" --region us-east-1 --query 'AssociationId' --output text)
echo "Associated Elastic IP: $ASSOC_ID"

# Get updated public IP
ELASTIC_IP=$(aws ec2 describe-addresses --allocation-ids "$ALLOCATION_ID" --region us-east-1 --query 'Addresses[0].PublicIp' --output text)

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║        ✅ EC2 INSTANCE SUCCESSFULLY CREATED!              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Instance Details:"
echo "   Instance ID: $INSTANCE_ID"
echo "   Public IP: $ELASTIC_IP"
echo "   Region: us-east-1"
echo "   VPC: $VPC_WITH_IGW"
echo "   Security Group: $SG_ID"
echo ""
echo "🔑 SSH Command:"
echo "   ssh -i ~/.ssh/food-app-key.pem ubuntu@$ELASTIC_IP"
echo ""
echo "⏳ Wait 2-3 minutes for Node.js and Nginx to install..."
echo ""
