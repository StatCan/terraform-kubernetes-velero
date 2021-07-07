variable "helm_namespace" {}

variable "helm_repository" {
  default = "https://vmware-tanzu.github.io/helm-charts"
}
variable "helm_repository_password" {
  default = ""
}
variable "helm_repository_username" {
  default = ""
}

variable "chart_version" {
  default = "2.13.6"
}

# Monitoring

variable "enable_monitoring" {
  type    = string
  default = "0"
}
variable "monitoring_namespace" {
  type    = string
  default = "monitoring"
}
variable "metrics_port" {
  type    = number
  default = 8085
}

# Backup Storage Location

variable "backup_storage_resource_group" {}
variable "backup_storage_account" {}
variable "backup_storage_bucket" {}

# Credentials

variable "azure_client_id" {}

variable "azure_client_secret" {
  default = ""
}

variable "azure_resource_group" {}

variable "azure_subscription_id" {}

variable "azure_tenant_id" {}

variable "values" {
  default = ""
  type    = string
}
