# Terraform configuration for a Linux VM
resource "azurerm_virtual_machine" "nexus" {
  name                  = "${var.environment}-nexus-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B4ms"

  storage_image_reference {
    publisher = "sonatypeinc1724257499617"
    offer     = "sonatype_nexus_repository_manager"
    sku       = "nxrm"
    version   = "0.0.3"
  }

  plan {
    name      = "nxrm"
    product   = "sonatype_nexus_repository_manager"
    publisher = "sonatypeinc1724257499617"
  }
  
  storage_os_disk {
    name              = "nexus-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    delete_os_disk_on_termination = true
  }

  os_profile {
    computer_name  = "devnexus-vm"
    admin_username = var.vmuser
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.vmuser}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  tags = {
    environment = "dev"
  }
}