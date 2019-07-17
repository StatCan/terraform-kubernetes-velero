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
}

# Namespace admin role
resource "kubernetes_role" "namespace-admin" {
  metadata {
    name = "tiller-velero"
    namespace = "${var.helm_namespace}"
  }

  # Read/write access to velero resources
  rule {
    api_groups = ["velero.io"]
    resources = ["*"]
    verbs = ["get", "list", "watch", "create", "update", "patch", "delete", "edit", "exec"]
  }

  depends_on = [
    "null_resource.dependency_getter",
  ]
}

# Namespace admin role bindings
resource "kubernetes_role_binding" "namespace-admins" {
  metadata {
    name = "tiller-velero"
    namespace = "${var.helm_namespace}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "tiller-velero"
  }

  # Users
  subject {
    kind = "ServiceAccount"
    name = "${var.helm_service_account}"
  }
}

resource "helm_release" "velero" {
  depends_on = ["null_resource.dependency_getter"]
  name = "velero"
  repository = "artifactory"
  chart = "velero"
  version = "${var.chart_version}"
  namespace = "${var.helm_namespace}"
  timeout = 1200

  values = [
    "${file("${path.module}/values/velero.yaml")}",
  ]

  # Backup Storage Location
  set {
    name = "velero.configuration.backupStorageLocation.bucket"
    value = "${var.backup_storage_bucket}"
  }

  set {
    name = "velero.configuration.backupStorageLocation.config.resourceGroup"
    value = "${var.backup_storage_resource_group}"
  }

  set {
    name = "velero.configuration.backupStorageLocation.config.storageAccount"
    value = "${var.backup_storage_account}"
  }

  # Credentials
  set {
    name = "velero.credentials.secretContents.AZURE_CLIENT_ID"
    value = "${var.azure_client_id}"
  }

  set {
    name = "velero.credentials.secretContents.AZURE_CLIENT_SECRENT"
    value = "${var.azure_client_secret}"
  }

  set {
    name = "velero.credentials.secretContents.AZURE_RESOURCE_GROUP"
    value = "${var.azure_resource_group}"
  }

  set {
    name = "velero.credentials.secretContents.AZURE_SUBSCRIPTION_ID"
    value = "${var.azure_subscription_id}"
  }

  set {
    name = "velero.credentials.secretContents.AZURE_TENANT_ID"
    value = "${var.azure_tenant_id}"
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
