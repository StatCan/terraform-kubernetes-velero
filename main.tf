resource "helm_release" "velero" {
  name = "velero"

  chart     = "velero"
  version   = var.chart_version
  namespace = var.helm_namespace
  timeout   = 1200

  repository          = var.helm_repository.name
  repository_username = var.helm_repository.username
  repository_password = var.helm_repository.password

  values = [
    var.values,
  ]

  # Credentials
  set {
    name  = "credentials.secretContents.cloud"
    value = <<EOF
AZURE_CLIENT_ID: ${var.cloud_provider_credentials.client_id}
AZURE_CLIENT_SECRET: ${var.cloud_provider_credentials.client_secret}
AZURE_RESOURCE_GROUP: ${var.cloud_provider_credentials.resource_group}
AZURE_SUBSCRIPTION_ID: ${var.cloud_provider_credentials.subscription_id}
AZURE_TENANT_ID: ${var.cloud_provider_credentials.tenant_id}
EOF
  }
}
