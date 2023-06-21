# Terraform Kubernetes Velero

## Introduction

This module deploys and configures Velero inside a Kubernetes Cluster.

## Security Controls

The following security controls can be met through configuration of this template:

* TBD

## Usage

```terraform
module "helm_velero" {
  source = "git::https://github.com/canada-ca-terraform-modules/terraform-kubernetes-velero.git?ref=v5.2.1"

  chart_version = "2.30.2"
  depends_on = [
    module.namespace_velero,
  ]

  helm_namespace = "velero"

  helm_repository = {
    name = "https://vmware-tanzu.github.io/helm-charts"
  }

  cloud_provider_credentials = {
    client_id       = var.velero_azure_client_id,
    client_secret   = var.velero_azure_client_secret,
    resource_group  = var.velero_azure_resource_group,
    subscription_id = var.velero_azure_subscription_id,
    tenant_id       = var.velero_azure_tenant_id
  }

  values = <<EOF
velero:
  image:
    repository: velero/velero
    tag: v1.9.0
    digest: sha256:97f13dd3d199e9277f57341e37cd6c80d9db65562e07eb60e1c13ff8618b4b0c
    pullPolicy: IfNotPresent
  initContainers:
    - name: velero-plugin-for-azure
      image: velero/velero-plugin-for-microsoft-azure:v1.5.0
      imagePullPolicy: IfNotPresent
      volumeMounts:
        - mountPath: /target
          name: plugins
  configuration:
    # Cloud provider being used (e.g. aws, azure, gcp).
    provider: azure
    # Parameters for the `default` BackupStorageLocation. See
    # https://velero.io/docs/v1.0.0/api-types/backupstoragelocation/
    backupStorageLocation:
    - name: default
      bucket: ${var.velero_backup_storage_bucket}
      config:
        resourceGroup: ${var.velero_backup_storage_resource_group}
        storageAccount: ${var.velero_backup_storage_account}
    # Parameters for the `default` VolumeSnapshotLocation. See
    # https://velero.io/docs/v1.0.0/api-types/volumesnapshotlocation/
    volumeSnapshotLocation:
      # Cloud provider where volume snapshots are being taken. Usually
      # should match `configuration.provider`. Required.,
      - name: default
  # Prometheus Operator ServiceMonitor for Velero metrics
  metrics:
    serviceMonitor:
      enabled: true
      additionalLabels:
        release: ${module.helm_kube_prometheus_stack.helm_release}
      namespace: ${module.namespace_monitoring.name}
  # Backup schedules to create.
  # Eg:
  # schedules:
  #   mybackup:
  #     schedule: "0 0 * * *"
  #     template:
  #       ttl: "240h"
  #       includedNamespaces:
  #        - foo
  schedules: {}
EOF
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the Helm chart | `any` | n/a | yes |
| <a name="input_cloud_provider_credentials"></a> [cloud\_provider\_credentials](#input\_cloud\_provider\_credentials) | Azure Credentials required to access the storage account | <pre>object({<br>    client_id       = string<br>    client_secret   = string<br>    resource_group  = string<br>    subscription_id = string<br>    tenant_id       = string<br>  })</pre> | n/a | yes |
| <a name="input_helm_namespace"></a> [helm\_namespace](#input\_helm\_namespace) | The namespace Helm will install the chart under | `any` | n/a | yes |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The repository where the Helm chart is stored | <pre>object({<br>    name     = string<br>    username = optional(string, "")<br>    password = optional(string, "")<br>  })</pre> | n/a | yes |
| <a name="input_enable_prometheusrules"></a> [enable\_prometheusrules](#input\_enable\_prometheusrules) | Adds PrometheusRules for velero alerts | `bool` | `true` | no |
| <a name="input_values"></a> [values](#input\_values) | Values to be passed to the Helm Chart | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_namespace"></a> [helm\_namespace](#output\_helm\_namespace) | n/a |
<!-- END_TF_DOCS -->

## History

| Date       | Release    | Change                                                                                              |
| ---------- | ---------- | --------------------------------------------------------------------------------------------------- |
| 2019-09-09 | 20190909.1 | 1st release                                                                                         |
| 2020-05-05 | 20200505.1 | Updates for Velero 1.3.x                                                                            |
| 2020-06-22 | v2.0.0     | Module now modified for Helm 3                                                                      |
| 2020-10-13 | v2.0.1     | Add the ability to specify a username and password                                                  |
| 2020-10-13 | v3.0.0     | Remove prefix for velero subchart due to moving to upstream chart                                   |
| 2020-12-09 | v3.1.0     | Add Service and ServiceMonitor for Prometheus Operator monitoring                                   |
| 2021-03-01 | v3.1.1     | Refactor for plan noise from ServiceMonitor and deprecated syntax                                   |
| 2021-04-12 | v3.2.0     | Add `servicemonitor_labels` variable                                                                |
| 2021-12-15 | v4.0.0     | Convert ServiceMonitor to `kubernetes_manifest` and update for Terraform v1                         |
| 2022-08-04 | v5.0.0     | Remove Prometheus Operator monitoring, now available through the chart                              |
| 2023-01-05 | v5.1.0     | Added Velero rules from kube-prometheus-stack                                                       |
| 2023-01-09 | v5.2.0     | Add runbook links to Prometheus rules                                                               |
| 2023-02-03 | v5.2.1     | Specify sensitive variables                                                                         |
| 2023-04-12 | v5.3.0     | In Velero rules that use aggregation, group by cluster as well.                                     |
| 2023-04-12 | v6.0.0     | Remove Backup Storage Location variables and consolidate cloud provider credential & helm repository variables into `cloud_provider_credentials` & `helm_repository` respectively. |

## Upgrading

### From v4.x to v5.x

If using the Prometheus Operator to monitor Velero metrics:
1. Ensure that `chart-version` is at or above `2.14.4`
1. Remove the Terraform variables `enable_monitoring`, `monitoring_namespace`, `servicemonitor_labels`, and `metrics_port`
1. Refer to the Velero Helm chart values in the [usage example](#usage) for the ServiceMonitor configuration.
    - The metrics Service is enabled by default. It can be explicitly disabled by setting `metrics.enabled` to `false`
    - The usage example places the ServiceMonitor into the same namespace as the Prometheus Operator. A different namespace can be specified, or no namespace can be specified defaulting to placement in the same namespace as Velero. In those cases, the Prometheus Operator may need to be configured to pick up ServiceMonitors from namespaces other than its own.

### From v3.x to v4.x

1. Note that in [Usage](#usage) the `dependencies` array has been replaced by the `depends_on` array.
1. If you have enabled and will continue to enable monitoring, a manual step is required for the Velero ServiceMonitor.
    - If a brief interruption in Velero metrics is acceptable, delete the ServiceMonitor prior to the upgrade. It will be recreated during the upgrade process.
    - Otherwise, import the ServiceMonitor into Terraform: `terraform import module.helm_velero.kubernetes_manifest.velero_servicemonitor[0] "apiVersion=monitoring.coreos.com/v1,kind=ServiceMonitor,namespace=monitoring,name=velero-monitor"`
      - If your monitoring namespace is not called `monitoring`, use the actual monitoring namespace name after `namespace=`
