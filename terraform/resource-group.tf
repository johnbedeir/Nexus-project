resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-resources"
  location = var.location
}