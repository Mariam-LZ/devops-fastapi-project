# Terraform documentation

## Objective

This Terraform stack provisions the virtual infrastructure used by the Kubernetes cluster.

Infrastructure is deployed on Proxmox VE and includes:
- control plane nodes
- worker nodes
- service nodes
- networking configuration

Terraform is responsible only for VM provisioning.
System and cluster configuration are handled separately through Ansible.

## Structure

main.tf
→ Proxmox VM resource definitions

providers.tf
→ Terraform providers configuration

variables.tf
→ Shared variables definitions

terraform.tfvars
→ Environment-specific values

vms.tf
→ VM definitions and sizing

## Provisioning flow

Terraform:
1. Connects to the Proxmox API
2. Clones VM templates
3. Applies VM resources and networking
4. Generates infrastructure inventory

Ansible:
5. Configures the operating system
6. Installs Kubernetes components
7. Bootstraps the cluster

## Important notes

- VM templates must already exist in Proxmox.
- QEMU guest agent is disabled during provisioning to avoid VM creation issues.
- Kubernetes nodes are separated by role (masters/workers/services).
- Terraform state locking must remain enabled.
- Sensitive values must not be committed to Git.