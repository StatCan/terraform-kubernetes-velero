# Terraform Kubernetes Velero

## Introduction

This module deploys and configures Velero inside a Kubernetes Cluster.

## Security Controls

The following security controls can be met through configuration of this template:

* TBD

## Dependancies

* None

## Usage

```terraform
module "helm_velero" {
  source = "github.com/canada-ca-terraform-modules/terraform-kubernetes-velero?ref=20190909.1"

  chart_version = "0.0.2"
  dependencies = [
    "${module.namespace_velero.depended_on}",
  ]

  helm_service_account = "tiller"
  helm_namespace = "velero"
  helm_repository = "artifactory"

  backup_storage_resource_group = "${var.velero_backup_storage_resource_group}"
  backup_storage_account = "${var.velero_backup_storage_account}"
  backup_storage_bucket = "${var.velero_backup_storage_bucket}"

  azure_client_id = "${var.velero_azure_client_id}"
  azure_client_secret = "${var.velero_azure_client_secret}"
  azure_resource_group = "${var.velero_azure_resource_group}"
  azure_subscription_id = "${var.velero_azure_subscription_id}"
  azure_tenant_id = "${var.velero_azure_tenant_id}"

  values = <<EOF
velero:
  image:
    repository: gcr.io/heptio-images/velero
    tag: v0.11.0
    pullPolicy: IfNotPresent

  configuration:
    backupStorageLocation:
      name: azure
EOF
}
```

## Variables Values

| Name                 | Type   | Required | Value                                               |
| -------------------- | ------ | -------- | --------------------------------------------------- |
| chart_version        | string | yes      | Version of the Helm Chart                           |
| dependencies         | string | yes      | Dependency name refering to namespace module        |
| helm_service_account | string | yes      | The service account for Helm to use                 |
| helm_namespace       | string | yes      | The namespace Helm will install the chart under     |
| helm_repository      | string | yes      | The repository where the Helm chart is stored       |
| values               | list   | no       | Values to be passed to the Helm Chart               |

## History

| Date     | Release    | Change      |
| -------- | ---------- | ----------- |
| 20190909 | 20190909.1 | 1st release |
