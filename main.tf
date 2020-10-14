# Part of a hack for module-to-module dependencies.
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
# and
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-473091030
# Make sure to add this null_resource.dependency_getter to the `depends_on`
# attribute to all resource(s) that will be constructed first within this
# module:
resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = "${join(",", var.dependencies)}"
  }

  lifecycle {
    ignore_changes = [
      triggers["my_dependencies"],
    ]
  }
}

resource "helm_release" "velero" {
  depends_on = ["null_resource.dependency_getter"]
  name       = "velero"

  repository          = var.helm_repository
  repository_username = var.helm_repository_username
  repository_password = var.helm_repository_password

  chart      = "velero"
  version    = var.chart_version
  namespace  = var.helm_namespace
  timeout    = 1200

  values = [
    "${var.values}",
  ]

  # Backup Storage Location
  set {
    name  = "velero.configuration.backupStorageLocation.bucket"
    value = var.backup_storage_bucket
  }

  set {
    name  = "velero.configuration.backupStorageLocation.config.resourceGroup"
    value = var.backup_storage_resource_group
  }

  set {
    name  = "velero.configuration.backupStorageLocation.config.storageAccount"
    value = var.backup_storage_account
  }

  # Credentials
  set {
    name  = "velero.credentials.secretContents.cloud"
    value = <<EOF
AZURE_CLIENT_ID: ${var.azure_client_id}
AZURE_CLIENT_SECRET: ${var.azure_client_secret}
AZURE_RESOURCE_GROUP: ${var.azure_resource_group}
AZURE_SUBSCRIPTION_ID: ${var.azure_subscription_id}
AZURE_TENANT_ID: ${var.azure_tenant_id}
EOF
  }
}

# Part of a hack for module-to-module dependencies.
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
resource "null_resource" "dependency_setter" {
  # Part of a hack for module-to-module dependencies.
  # https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
  # List resource(s) that will be constructed last within the module.
  depends_on = [
    "helm_release.velero"
  ]
}
