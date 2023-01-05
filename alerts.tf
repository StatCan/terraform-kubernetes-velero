locals {
  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    "app.kubernetes.io/part-of"    = "velero"
    "app.kubernetes.io/version"    = "v5.1.0"
  }
}

resource "kubernetes_manifest" "prometheusrule_velero_alerts" {
  count = var.enable_prometheusrules ? 1 : 0
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "PrometheusRule"
    "metadata" = {
      "name"      = "velero-alerts"
      "namespace" = var.helm_namespace
      "labels"    = merge(local.common_labels, { "app.kubernetes.io/name" = "velero-alerts" })
      "annotations" = {
        "rules-definition" = "https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-velero/-/tree/master/prometheus_rules/velero_rules.yaml"
      }
    }
    "spec" = yamldecode(file("${path.module}/prometheus_rules/velero_rules.yaml"))
  }
}
