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
  source = "git::https://github.com/canada-ca-terraform-modules/terraform-kubernetes-velero.git?ref=v2.0.1"

  chart_version = "0.1.0"
  dependencies = [
    "${module.namespace_velero.depended_on}",
  ]

  helm_namespace       = "velero"
  helm_repository      = "stable"

  backup_storage_resource_group = var.velero_backup_storage_resource_group
  backup_storage_account        = var.velero_backup_storage_account
  backup_storage_bucket         = var.velero_backup_storage_bucket

  azure_client_id       = var.velero_azure_client_id
  azure_client_secret   = var.velero_azure_client_secret
  azure_resource_group  = var.velero_azure_resource_group
  azure_subscription_id = var.velero_azure_subscription_id
  azure_tenant_id       = var.velero_azure_tenant_id

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

## History

| Date     | Release    | Change                                              |
| -------- | ---------- | --------------------------------------------------- |
| 20190909 | 20190909.1 | 1st release                                         |
| 20200505 | 20200505.1 | Updates for Velero 1.3.x                            |
| 20200622 | v2.0.0     | Module now modified for Helm 3                      |
| 20201013 | v2.0.1     | Add the ability to specify a username and password. |
