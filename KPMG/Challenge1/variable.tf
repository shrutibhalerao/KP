variable "project_name" {
  default = "az"
}

variable "environment" {
  default = "dev"
}

variable "region" {
  default = {
    scus = "South Central US",
    ncus = "North Central US",
    eus = "East US"
  }
}

variable "tenant_id" {
  description = "Tenant ID"
  default     = ""
}

variable "subscription_id" {
  description = "Subscription ID"
  default     = ""
}

variable "web_instances" {
    type =map (any)
  default = {
    vm_size  = "Standard_B1s"  # VM size
    storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
}

variable "app_instances" {
    type =map (any)
default = {
    vm_size  = "Standard_B1s"  # VM size
    storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
}

variable "administrator_login" {
  default = "adminuser"
}

variable "administrator_login_password" {
  default = "welcome123"
}

variable "address_space" {
  default = "10.0.0.0/16"
}

variable "address_space" {
  default = "10.0.1.0/24"
}