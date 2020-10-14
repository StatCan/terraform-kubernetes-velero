variable "helm_namespace" {}

variable "helm_repository" {}
variable "helm_repository_password" {
  default = ""
}
variable "helm_repository_username" {
  default = ""
}

variable "chart_version" {}

# Backup Storage Location

variable "backup_storage_resource_group" {}
variable "backup_storage_account" {}
variable "backup_storage_bucket" {}

# Credentials

variable "azure_client_id" {}
variable "azure_client_secret" {}

variable "azure_resource_group" {}

variable "azure_subscription_id" {}

variable "azure_tenant_id" {}

variable "dependencies" {
  type = "list"
}

variable "values" {
  default = ""
  type    = "string"
}
