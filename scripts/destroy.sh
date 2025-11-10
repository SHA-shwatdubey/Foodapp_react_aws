#!/bin/bash

# Cleanup script - Destroy all AWS resources created by Terraform

set -e

echo "⚠️  WARNING: This will destroy all AWS resources!"
read -p "Type 'destroy' to confirm: " confirm

if [ "$confirm" != "destroy" ]; then
    echo "❌ Cancelled"
    exit 1
fi

echo "🗑️  Destroying AWS resources..."

cd terraform
terraform destroy -auto-approve

echo "✅ Resources destroyed!"
