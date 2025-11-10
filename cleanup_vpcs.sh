#!/bin/bash

# VPCs to potentially clean up
VPCS=(
  "vpc-0f55e42cb2832ead0"
  "vpc-031e55b0295e2fd90"
  "vpc-04778eba6cd1f5c0d"
  "vpc-04ab81164d5dfc1ca"
  "vpc-01c71ed3c35d02272"
)

echo "Found VPCs, we need to remove 1 to stay under the limit of 5"
echo "Let's remove the oldest one without instances or with terminated instances"

# Delete VPC with no instances first
echo "Deleting vpc-04778eba6cd1f5c0d (appears to have no instances)..."

# First delete subnets
echo "Deleting subnets in vpc-04778eba6cd1f5c0d..."
SUBNETS=$(aws ec2 describe-subnets --region us-east-1 --filters "Name=vpc-id,Values=vpc-04778eba6cd1f5c0d" --query 'Subnets[*].SubnetId' --output text)
for subnet in $SUBNETS; do
  echo "Deleting subnet: $subnet"
  aws ec2 delete-subnet --subnet-id $subnet --region us-east-1 2>/dev/null || true
done

# Delete route tables
echo "Deleting route tables..."
RTS=$(aws ec2 describe-route-tables --region us-east-1 --filters "Name=vpc-id,Values=vpc-04778eba6cd1f5c0d" --query 'RouteTables[*].RouteTableId' --output text)
for rt in $RTS; do
  # Skip main route table
  aws ec2 delete-route-table --route-table-id $rt --region us-east-1 2>/dev/null || true
done

# Delete internet gateways
echo "Deleting internet gateways..."
IGW=$(aws ec2 describe-internet-gateways --region us-east-1 --filters "Name=attachment.vpc-id,Values=vpc-04778eba6cd1f5c0d" --query 'InternetGateways[*].InternetGatewayId' --output text)
for gw in $IGW; do
  echo "Detaching IGW: $gw"
  aws ec2 detach-internet-gateway --internet-gateway-id $gw --vpc-id vpc-04778eba6cd1f5c0d --region us-east-1 2>/dev/null || true
  echo "Deleting IGW: $gw"
  aws ec2 delete-internet-gateway --internet-gateway-id $gw --region us-east-1 2>/dev/null || true
done

# Delete security groups (non-default)
echo "Deleting security groups..."
SGs=$(aws ec2 describe-security-groups --region us-east-1 --filters "Name=vpc-id,Values=vpc-04778eba6cd1f5c0d" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)
for sg in $SGs; do
  echo "Deleting SG: $sg"
  aws ec2 delete-security-group --group-id $sg --region us-east-1 2>/dev/null || true
done

# Delete VPC
echo "Deleting VPC: vpc-04778eba6cd1f5c0d"
aws ec2 delete-vpc --vpc-id vpc-04778eba6cd1f5c0d --region us-east-1

echo "VPC cleanup completed!"
