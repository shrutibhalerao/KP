
data "azurerm_client_config" "current" {}
data azurerm_subscription "current" {}

data "azurerm_virtual_machine" "instance" {
  name                = "${var.project_name}-${var.environment}-${var.region}-vm"           
  resource_group_name = "${var.project_name}-${var.environment}-${var.region}-rg2"    
}

output "instance_metadata" {
  value = data.azurerm_virtual_machine.instance
}


# view the instance metadata using the terraform output command.
# $ terraform output instance_metadata