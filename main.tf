resource "helm_release" "velero" {
  name = "velero"

  repository          = var.helm_repository
  repository_username = var.helm_repository_username
  repository_password = var.helm_repository_password

  chart     = "velero"
  version   = var.chart_version
  namespace = var.helm_namespace
  timeout   = 1200

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

  metadata {
    name      = "velero-metrics"
    namespace = var.helm_namespace
    labels = {
      "app.kubernetes.io/name"     = "velero"
      "app.kubernetes.io/instance" = "velero"
    }
  }
  spec {
    selector = {
      name                         = "velero"
      "app.kubernetes.io/name"     = "velero"
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

resource "kubernetes_manifest" "velero_servicemonitor" {
  count = var.enable_monitoring ? 1 : 0

  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "labels"    = var.servicemonitor_labels
      "name"      = "velero-monitor"
      "namespace" = var.monitoring_namespace
    }
    "spec" = {
      "endpoints" = [
        {
          "port" = "monitoring"
        },
      ]
      "namespaceSelector" = {
        "matchNames" = [
          var.helm_namespace,
        ]
      }
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/instance" = "velero"
          "app.kubernetes.io/name"     = "velero"
        }
      }
    }
  }
}
