variable "helm_namespace" {
  description = "The namespace Helm will install the chart under"
}

variable "helm_repository" {
  description = "The repository where the Helm chart is stored"
}
variable "helm_repository_password" {
  type        = string
  nullable    = false
  default     = ""
  description = "The password of the repository where the Helm chart is stored"
  sensitive   = true
}
variable "helm_repository_username" {
  type        = string
  nullable    = false
  default     = ""
  description = "The username of the repository where the Helm chart is stored"
  sensitive   = true
}

variable "chart_version" {
  description = "Version of the Helm chart"
}

# Backup Storage Location

variable "backup_storage_resource_group" {
  description = "The resource group containing the bucket"
}
variable "backup_storage_account" {
  description = "The storage account containing the bucket"
}
variable "backup_storage_bucket" {
  description = "The bucket to use for backing up"
}

# Credentials

variable "azure_client_id" {
  description = "The Azure Client ID to use to access the storage account"
  sensitive   = true
}
variable "azure_client_secret" {
  description = "The Client Secret to use for the storage backend"
  sensitive   = true
}

variable "azure_resource_group" {
  description = "The Resource Group in where the Client ID resides"
}

variable "azure_subscription_id" {
  description = "The Azure Subscription ID"
}

variable "azure_tenant_id" {
  description = "The Azure Tenant ID"
  sensitive   = true
}

variable "values" {
  default     = ""
  type        = string
  description = "Values to be passed to the Helm Chart"
}

variable "enable_prometheusrules" {
  type        = bool
  default     = true
  description = "Adds PrometheusRules for velero alerts"
}
