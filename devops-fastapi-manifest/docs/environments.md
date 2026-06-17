# Environments

This project is designed to be deployed across multiple Kubernetes environments using one shared Helm chart and one values file per environment.

## Environment strategy

Each environment is isolated using a dedicated Kubernetes namespace and a dedicated Helm values file.

| Environment | Namespace | Values file |
|---|---|---|
| Development | `dev` | `helm/fastapi-app/values-dev.yaml` |
| Production | `prod` | `helm/fastapi-app/values-prod.yaml` |

## Development

The development environment is used to validate features and infrastructure changes early.

Expected characteristics:

- lower resource requirements
- minimal replica count
- Adminer can be enabled for debugging
- test credentials and development secrets only
- faster iteration cycle

## Production

The production environment should be the most restricted and stable environment.

Expected characteristics:

- Adminer disabled
- stricter access rules
- production secrets managed only through Ansible Vault
- stable image update policy
- backups and restore procedures required
- monitoring and alerting required

## Helm values

Common configuration should stay in:
    helm/fastapi-app/values.yaml

Environment-specific overrides should stay in:

    helm/fastapi-app/values-dev.yaml
    helm/fastapi-app/values-prod.yaml

## Network policies

Network policies are planned to restrict traffic between application components.

The cluster uses Calico, which supports Kubernetes NetworkPolicy resources.

For now, network policies are disabled by default in the Helm chart until they can be tested safely on the running cluster.

Expected future restrictions:

- frontend traffic should be allowed to reach the backend
- backend traffic should be allowed to reach PostgreSQL
- backend pods should keep access to DNS
- Adminer access should stay limited to debugging/internal usage
- production should use stricter rules than development

Network policies should be enabled progressively to avoid blocking required application traffic.

### PostgreSQL namespace handling

The Bitnami PostgreSQL dependency uses namespaceOverride per environment to ensure that database resources are deployed in the same namespace as the application.

Example:
```YAML
postgresql:
  namespaceOverride: dev
  ```

### Secrets

Secrets are not stored in this repository.

They are expected to be created by the infrastructure automation layer using Ansible Vault before Argo CD synchronizes the application.

See:

docs/secret-management.md

### Notes

Replica counts, resource limits, autoscaling thresholds, domain names, ingress and Gateway API configuration, monitoring integration, backup strategies, and security policies may evolve as the infrastructure platform and Kubernetes cluster implementation progress.

Some platform components such as Traefik, Gateway API, cert-manager, Velero, Prometheus, Grafana, and Argo CD Image Updater are managed separately through the infrastructure repository and may introduce additional application configuration over time.