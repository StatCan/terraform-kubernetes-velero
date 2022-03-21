# Terraform Kubernetes Velero

## Introduction

This module deploys and configures Velero inside a Kubernetes Cluster.

## Security Controls

The following security controls can be met through configuration of this template:

* TBD

## Dependencies

* None

## Optional (depending on options configured):

* None

## Usage

```terraform
module "helm_velero" {
  source = "git::https://github.com/canada-ca-terraform-modules/terraform-kubernetes-velero.git?ref=v4.0.0"

  chart_version = "2.13.6"
  depends_on = [
    module.namespace_velero,
  ]

  helm_namespace       = "velero"
  helm_repository      = "https://vmware-tanzu.github.io/helm-charts"

  backup_storage_resource_group = var.velero_backup_storage_resource_group
  backup_storage_account        = var.velero_backup_storage_account
  backup_storage_bucket         = var.velero_backup_storage_bucket

  azure_client_id       = var.velero_azure_client_id
  azure_client_secret   = var.velero_azure_client_secret
  azure_resource_group  = var.velero_azure_resource_group
  azure_subscription_id = var.velero_azure_subscription_id
  azure_tenant_id       = var.velero_azure_tenant_id

  enable_monitoring     = true
  monitoring_namespace  = module.namespace_monitoring.name
  servicemonitor_labels = {
    app     = "velero"
    release = module.helm_kube_prometheus_stack.helm_release
  }
  metrics_port          = 8085

  values = <<EOF
velero:
  image:
    repository: velero/velero
    tag: v1.3.1
    digest: sha256:0c74f1d552ef25a4227e582f4c0e6b3db3402abe196595ee9442ceeb43b99696
    pullPolicy: IfNotPresent
  initContainers:
    - name: velero-plugin-for-azure
      image: velero/velero-plugin-for-microsoft-azure:v1.0.1
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
      name: default
    # Parameters for the `default` VolumeSnapshotLocation. See
    # https://velero.io/docs/v1.0.0/api-types/volumesnapshotlocation/
    volumeSnapshotLocation:
      # Cloud provider where volume snapshots are being taken. Usually
      # should match `configuration.provider`. Required.,
      name: default
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

## Variables Values

| Name                          | Type   | Required | Value                                                         |
| ----------------------------- | ------ | -------- | ------------------------------------------------------------- |
| chart_version                 | string | yes      | Version of the Helm Chart                                     |
| dependencies                  | string | yes      | Dependency name refering to namespace module                  |
| helm_namespace                | string | yes      | The namespace Helm will install the chart under               |
| helm_repository               | string | yes      | The repository where the Helm chart is stored                 |
| helm_repository_username      | string | no       | The username of the repository where the Helm chart is stored |
| helm_repository_password      | string | no       | The password of the repository where the Helm chart is stored |
| values                        | string | no       | Values to be passed to the Helm Chart                         |
| backup_storage_resource_group | string | yes      | The resource group containing the bucket.                     |
| backup_storage_account        | string | yes      | The storage account containing the bucket.                    |
| backup_storage_bucket         | string | yes      | The bucket to use for backing up.                             |
| azure_client_id               | string | yes      | The Azure Client ID to use to access the storage account.     |
| azure_client_secret           | string | yes      | The Client Secret to use for the storage backend.             |
| azure_resource_group          | string | yes      | The Resource Group in where the Client ID resides.            |
| azure_subscription_id         | string | yes      | The Azure Subscription ID.                                    |
| azure_tenant_id               | string | yes      | The Azure Tenant ID.                                          |
| enable_monitoring             | bool   | no       | Adds metrics Service and Prometheus Operator ServiceMonitor.  |
| monitoring_namespace          | string | no       | The namespace where Prometheus Operator is installed.         |
| servicemonitor_labels         | map    | no       | The labels of the Velero ServiceMonitor.                      |
| metrics_port                  | number | no       | The service port for Prometheus metrics.                      |

## History

| Date       | Release    | Change                                                                      |
| ---------- | ---------- | --------------------------------------------------------------------------- |
| 2019-09-09 | 20190909.1 | 1st release                                                                 |
| 2020-05-05 | 20200505.1 | Updates for Velero 1.3.x                                                    |
| 2020-06-22 | v2.0.0     | Module now modified for Helm 3                                              |
| 2020-10-13 | v2.0.1     | Add the ability to specify a username and password                          |
| 2020-10-13 | v3.0.0     | Remove prefix for velero subchart due to moving to upstream chart           |
| 2020-12-09 | v3.1.0     | Add Service and ServiceMonitor for Prometheus Operator monitoring           |
| 2021-03-01 | v3.1.1     | Refactor for plan noise from ServiceMonitor and deprecated syntax           |
| 2021-04-12 | v3.2.0     | Add `servicemonitor_labels` variable                                        |
| 2021-12-15 | v4.0.0     | Convert ServiceMonitor to `kubernetes_manifest` and update for Terraform v1 |

## Upgrading

### From v3.x to v4.x

1. Note that in [Usage](#usage) the `dependencies` array has been replaced by the `depends_on` array.
1. If you have enabled and will continue to enable monitoring, a manual step is required for the Velero ServiceMonitor.
    - If a brief interruption in Velero metrics is acceptable, delete the ServiceMonitor prior to the upgrade. It will be recreated during the upgrade process. 
    - Otherwise, import the ServiceMonitor into Terraform: `terraform import module.helm_velero.kubernetes_manifest.velero_servicemonitor[0] "apiVersion=monitoring.coreos.com/v1,kind=ServiceMonitor,namespace=monitoring,name=velero-monitor"`
      - If your monitoring namespace is not called `monitoring`, use the actual monitoring namespace name after `namespace=`
