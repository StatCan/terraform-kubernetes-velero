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
  depends_on = [null_resource.dependency_getter]
  name       = "velero"

  repository          = var.helm_repository
  repository_username = var.helm_repository_username
  repository_password = var.helm_repository_password

  chart      = "velero"
  version    = var.chart_version
  namespace  = var.helm_namespace
  timeout    = 1200

  values = [
    var.values,
  ]

  # Backup Storage Location
  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = var.backup_storage_bucket
  }

  set {
    name  = "configuration.backupStorageLocation.config.resourceGroup"
    value = var.backup_storage_resource_group
  }

  set {
    name  = "configuration.backupStorageLocation.config.storageAccount"
    value = var.backup_storage_account
  }

  # Credentials
  set {
    name  = "credentials.secretContents.cloud"
    value = <<EOF
AZURE_CLIENT_ID: ${var.azure_client_id}
AZURE_CLIENT_SECRET: ${var.azure_client_secret}
AZURE_RESOURCE_GROUP: ${var.azure_resource_group}
AZURE_SUBSCRIPTION_ID: ${var.azure_subscription_id}
AZURE_TENANT_ID: ${var.azure_tenant_id}
EOF
  }
}

resource "kubernetes_service" "velero" {
  count = var.enable_monitoring ? 1 : 0
  depends_on = [null_resource.dependency_getter]

  metadata {
    name = "velero-metrics"
    namespace = var.helm_namespace
    labels = {
      "app.kubernetes.io/name" = "velero-metrics"
      "app.kubernetes.io/instance" = "velero-metrics"
    }
  }
  spec {
    selector = {
      name = "velero"
      "app.kubernetes.io/name" = "velero"
      "app.kubernetes.io/instance" = "velero"
    }
    session_affinity = "ClientIP"
    port {
      name        = "monitoring"
      port        = var.metrics_port
      target_port = "monitoring"
    }
  }
}

resource "local_file" "velero-servicemonitor" {
  count = var.enable_monitoring ? 1 : 0
  depends_on = [null_resource.dependency_getter]
  
  content     = <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: velero-monitor
  namespace: ${var.monitoring_namespace}
  labels:
    app: velero-monitor
    release: prometheus-operator
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: velero-metrics
      app.kubernetes.io/instance: velero-metrics
  namespaceSelector:
    matchNames:
    - ${var.helm_namespace}
  endpoints:
  - port: monitoring
EOF
  filename = "${path.module}/config/velero/velero-servicemonitor.yaml"
}

resource "null_resource" "apply_servicemonitor" {
  count = var.enable_monitoring ? 1 : 0
  depends_on = [null_resource.dependency_getter]
  
  provisioner "local-exec" {
    command = "kubectl -n ${var.monitoring_namespace} apply -f ${path.module}/config/velero/velero-servicemonitor.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl -n ${var.monitoring_namespace} delete -f ${path.module}/config/velero/velero-servicemonitor.yaml"
  }
}

# Part of a hack for module-to-module dependencies.
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
resource "null_resource" "dependency_setter" {
  # Part of a hack for module-to-module dependencies.
  # https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
  # List resource(s) that will be constructed last within the module.
  depends_on = [
    helm_release.velero
  ]
}
