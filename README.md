# Devops-fastapi-project

This repository is the capstone project completed as part of a DevOps training program. The objective was to deploy a FastAPI application provided by the training organization in a microservices architecture on a brand new environment, in a secure manner, with Traefik as the entry point and reverse proxy.

The project is organized into three distinct directories, each corresponding to a specific layer of the infrastructure.

---

## Repository Structure
devops-fastapi-project/

├── devops-fastapi-app/

├── devops-fastapi-infra/

└── devops-fastapi-manifest/

**devops-fastapi-app** contains the FastAPI application source code, the Dockerfile, and the CI/CD pipeline configuration for building and pushing the Docker image.

**devops-fastapi-infra** contains all the Infrastructure as Code resources. The virtual machines are provisioned on a self-hosted Proxmox hypervisor using Terraform, and configured using Ansible (packages, users, Kubernetes prerequisites).

**devops-fastapi-manifest** contains the Kubernetes manifests and Helm charts used to deploy the application and its dependencies on the cluster. GitOps is handled through ArgoCD, which watches this repository and synchronizes the cluster state automatically.

---

## Stack

| Layer | Technology |
|---|---|
| Provisioning | Terraform, Proxmox |
| Configuration | Ansible |
| Containerization | Docker |
| Orchestration | Kubernetes (K3s) |
| GitOps | ArgoCD |
| Packaging | Helm |
| Reverse proxy | Traefik |
| TLS | cert-manager |
| Monitoring | Prometheus, Grafana |
| Backup | Velero, pg_dump, MinIO |
| Database | PostgreSQL |

---

## Key Features

The application is deployed in microservices mode on a Kubernetes cluster hosted on Proxmox virtual machines. All infrastructure is described as code and fully reproducible. Traefik serves as the single entry point, handling routing and TLS termination. Certificates are automatically provisioned and renewed via cert-manager. The cluster state is managed declaratively through ArgoCD. Monitoring is ensured by a Prometheus and Grafana stack, and a multi-layer backup strategy covers both persistent volumes (Velero) and the PostgreSQL database (pg_dump stored on MinIO).