variable "helm_namespace" {
  description = "The namespace Helm will install the chart under"
}

variable "chart_version" {
  description = "Version of the Helm chart"
}

variable "helm_repository" {
  description = "The repository where the Helm chart is stored"
  type = object({
    name     = string
    username = optional(string, "")
    password = optional(string, "")
  })
  sensitive = true
}

# Credentials

variable "cloud_provider_credentials" {
  description = "Azure Credentials required to access the storage account"
  type = object({
    client_id       = string
    client_secret   = string
    resource_group  = string
    subscription_id = string
    tenant_id       = string
  })
  sensitive = true
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
