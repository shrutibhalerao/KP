data "azurerm_client_config" "current" {}
data azurerm_subscription "current" {}

# Create resource group
resource "azurerm_resource_group" "core_rg" {
  name     = "${var.project_name}-${var.environment}-${var.region}-rg"
  location = var.region # location
}

# Create Azure Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-${var.environment}-${var.region}-vnet"
  address_space       = var.address_space
  location            = var.region  #  region
  resource_group_name = "${var.project_name}-${var.environment}-${var.region}"
}
# Create Azure Subnet for the app tier
resource "azurerm_subnet" "app_subnet" {
  name                 = "${var.project_name}-${var.environment}-${var.region}-app-subnet"
  resource_group_name  = "${var.project_name}-${var.environment}-${var.region}-rg"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes      = var.address_prefixes  #  subnet CIDR
}

# Presentation Layer

# Create Azure Load Balancer for web tier
resource "azurerm_lb" "web_lb" {
  name                ="${var.project_name}-${var.environment}-${var.region}-web-lb"
  location            = var.region  #  region
  resource_group_name = "${var.project_name}-${var.environment}-${var.region}-rg"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.web_lb_public_ip.id
  }
}

# Create Azure Virtual Machines for web tier
resource "azurerm_virtual_machine" "web_instances" {
  count                 = 2  #  desired number of instances
  name                  = "${var.project_name}-${var.environment}-${var.region}-web-vm-${count.index}"
  location              = var.region  #  region
  resource_group_name   = "${var.project_name}-${var.environment}-${var.region}-rg"
  network_interface_ids = [azurerm_network_interface.web_nic.id]
  vm_size               = var.web_instances.vm_size
  storage_image_reference {
    publisher = var.web_instances.publisher
    offer     = var.web_instances.offer
    sku       = var.web_instances.sku
    version   = var.web_instances.version
  }
}

# Application Layer

resource "azurerm_virtual_machine" "app_instances" {
  count                 = 2  #  desired number of instances
  name                  = "${var.project_name}-${var.environment}-${var.region}-app-vm-${count.index}"
  location              = var.region  # Update with your desired region
  resource_group_name   = "${var.project_name}-${var.environment}-${var.region}-rg"
  network_interface_ids = [azurerm_network_interface.app_nic.id]
  vm_size               = var.app_instances.vm_size  #  desired VM size
  storage_image_reference {
    publisher = var.app_instances.publisher
    offer     = var.app_instances.offer
    sku       = var.app_instances.sku
    version   = var.app_instances.version
  }
}

# Data Layer

# Create Azure SQL Database for the data layer
resource "azurerm_sql_server" "database_server" {
  name                         = "${var.project_name}-${var.environment}-${var.region}-database-server"
  resource_group_name          = "${var.project_name}-${var.environment}-${var.region}-rg"
  location                     = var.region
  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
}

resource "azurerm_sql_database" "database" {
  name                         = "${var.project_name}-${var.environment}-${var.region}-db"
  resource_group_name          = "${var.project_name}-${var.environment}-${var.region}-rg"
  location                     = var.region
  server_name                  = azurerm_sql_server.database_server.name
  edition                      = "Basic"
  requested_service_objective_name = "Basic"
  collation                    = "SQL_Latin1_General_CP1_CI_AS"
}

# Connectivity between 3-Layers

# Create Azure Virtual Network Rule to allow access from app tier
resource "azurerm_sql_virtual_network_rule" "app_network_rule" {
  name                = "${var.project_name}-${var.environment}-${var.region}-app-network-rule"
  server_name         = azurerm_sql_server.database_server.name
  resource_group_name = "${var.project_name}-${var.environment}-${var.region}-rg"
  subnet_id           = azurerm_subnet.app_subnet.id
}

# Connect the web tier to the application tier
resource "azurerm_lb_backend_address_pool" "web_backend_pool" {
  name                = "${var.project_name}-${var.environment}-${var.region}-web-backend-pool"
  loadbalancer_id     = azurerm_lb.web_lb.id
  resource_group_name = "${var.project_name}-${var.environment}-${var.region}-rg"

  backend_addresses {
    ip_address = azurerm_virtual_machine.web_instances.*.private_ip_address
  }
}

# Connect the application tier to the database tier
resource "azurerm_virtual_machine_extension" "app_db_extension" {
  name                 = "${var.project_name}-${var.environment}-${var.region}-app-db-extension"
  virtual_machine_id   = azurerm_virtual_machine.app_instances[0].id
  resource_group_name  = "${var.project_name}-${var.environment}-${var.region}-rg"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-get update && sudo apt-get install -y mysql-client"
    }
  SETTINGS
}

# Configure database connection string in the application tier
resource "azurerm_virtual_machine_extension" "app_db_connection" {
  name                 = "${var.project_name}-${var.environment}-${var.region}-app-db-connection"
  virtual_machine_id   = azurerm_virtual_machine.app_instances[0].id
  resource_group_name  = "${var.project_name}-${var.environment}-${var.region}-rg"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "echo 'export DB_CONNECTION_STRING=<YOUR_DATABASE_CONNECTION_STRING>' >> /etc/environment"
    }
  SETTINGS
}
