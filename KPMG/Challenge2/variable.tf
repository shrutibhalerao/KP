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
    eus2 = "East US"
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