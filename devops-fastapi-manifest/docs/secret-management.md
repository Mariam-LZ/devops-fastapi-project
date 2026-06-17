# Required Secrets

Secrets are managed outside this repository.
This document only lists the Kubernetes secrets expected by the Helm chart.
Secrets are created by the infrastructure repository using Ansible Vault.
The Helm chart only references existing Kubernetes secrets.

## PostgreSQL Secret

Kubernetes secret:
fastapi-postgres-secret

Namespaces:
- dev
- prod

Vault variables:
- vault_postgres_admin_password
- vault_postgres_app_password

Used by:
- Bitnami PostgreSQL Helm chart

## GitLab Registry Secret

Kubernetes secret:
gitlab-registry

Vault variables:
- vault_gitlab_registry_username
- vault_gitlab_registry_password

Used by:
- backend deployment
- frontend deployment
- backend prestart job

## Argo CD Image Updater Git Secret

Vault variables:
- vault_gitlab_image_updater_username
- vault_gitlab_image_updater_token

Used by:
- Argo CD Image Updater

Purpose:
- Git write-back for manifest repository