#!/bin/bash

set -e

# Variables
TERRAFORM_DIR="terraform"
RESOURCE_GROUP="dev-resources" # Replace with your resource group name
DISK_NAME="nexus-os-disk"

# Destroy Terraform resources
cd "$TERRAFORM_DIR"
terraform destroy -auto-approve

# Check if the OS disk still exists and delete it
az disk delete --resource-group "$RESOURCE_GROUP" --name "$DISK_NAME" --yes --no-wait

echo "Nexus VM and associated OS disk destroyed successfully."
