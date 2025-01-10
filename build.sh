#!/bin/bash

set -e

# Variables
TERRAFORM_DIR="terraform"
# NEED TO BE CHANGED
# Generate SSH Key using "ssh keygen" command
PRIVATE_KEY="~/.ssh/id_rsa"
VM_USER="johnydev"
#-------------
NEXUS_PORT=8081

# Step 1: Accept the terms for the nexus image
az vm image terms accept \
    --publisher sonatypeinc1724257499617 \
    --offer sonatype_nexus_repository_manager \
    --plan nxrm

echo "-------------------------------------------------------------------"

# Step 2: Create the Nexus VM on Azure
cd "$TERRAFORM_DIR"
terraform init
terraform apply -auto-approve

echo "Fetching the VM public IP from Terraform output..."
VM_IP=$(terraform output -raw vm_public_ip)

if [ -z "$VM_IP" ]; then
  echo "Error: Unable to fetch VM IP. Ensure Terraform outputs the IP."
  exit 1
fi

sleep 20s 

echo "VM Public IP: $VM_IP"

echo "Nexus deployed successfully. Access it at http://$VM_IP:$NEXUS_PORT"

echo "-------------------------------------------------------------------"
echo "Nexus Username:"
echo "admin"
echo "-------------------------------------------------------------------"

# Step 3: Connect to the VM and retrieve the Nexus admin password
echo "Connecting to the VM and retrieving the Nexus admin password..."
ssh -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no "$VM_USER@$VM_IP" << EOF
  set -e
  if [ -f /opt/sonatype-work/nexus3/admin.password ]; then
    echo "Nexus Admin Password:"
    cat /opt/sonatype-work/nexus3/admin.password
  else
    echo "Error: Nexus admin password file not found at /opt/sonatype-work/nexus3/admin.password"
  fi
EOF