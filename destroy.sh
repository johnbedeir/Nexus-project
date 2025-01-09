#!/bin/bash

set -e

# Variables
TERRAFORM_DIR="terraform"

# Destroy Nexus VM
cd "$TERRAFORM_DIR"
terraform destroy -auto-approve

echo "Nexus VM Destroyed successfully."