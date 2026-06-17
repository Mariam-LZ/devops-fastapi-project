# Ansible documentation

## Objective

This Ansible stack prepares and configures the Kubernetes infrastructure
after VM provisioning through Terraform.

Roles are separated by responsibility:
- system preparation
- container runtime
- Kubernetes installation
- control plane bootstrap
- HA load balancing
- platform services

## Role order

common
→ OS preparation, kernel modules, networking, sysctl

containerd
→ Kubernetes container runtime

kubernetes
→ kubelet, kubeadm, kubectl installation

masters
→ control plane initialization and HA join

workers
→ worker node join

api-load-balancer
→ HAProxy + Keepalived virtual IP

helm / argocd / k8s-secrets
→ platform services and GitOps

## Important notes

- Kubernetes packages are pinned to avoid accidental upgrades.
- Sysctl networking settings are centralized in the `common` role.
- HAProxy and Keepalived expose a stable Kubernetes API endpoint.
- containerd is used as the Kubernetes container runtime.
- Secrets are managed separately from Kubernetes manifests.

## PostgreSQL backup with Velero (Longhorn PVC)

The `velero` role creates two schedules:
- a cluster-wide backup schedule
- a dedicated PostgreSQL schedule for namespaces defined by
	`velero_postgres_included_namespaces`

The PostgreSQL schedule enables:
- `snapshotVolumes: true` for CSI snapshots when available
- `defaultVolumesToFsBackup: true` as filesystem backup fallback (Kopia)
- optional `pg_dump` pre-hook executed in PostgreSQL pod before backup

Default variables are defined in
`ansible/inventory/group_vars/all/main.yml`:
- `velero_postgres_backup_enabled`
- `velero_postgres_schedule_name`
- `velero_postgres_schedule_cron`
- `velero_postgres_included_namespaces`
- `velero_postgres_backup_ttl`
- `velero_postgres_pgdump_enabled`
- `velero_postgres_pgdump_selector_key`
- `velero_postgres_pgdump_selector_value`
- `velero_postgres_pgdump_container`

If `velero_postgres_pgdump_enabled: true`, Velero runs `pg_dump` before the
backup and writes dump files to the PostgreSQL data volume under:

`velero_postgres_pgdump_dump_dir`

Important:
- `velero_postgres_pgdump_selector_*` must match your PostgreSQL pod labels
- `velero_postgres_pgdump_container` must match the container name in the pod

Apply/update Velero configuration:

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy.yml --tags velero
```

Create a one-shot PostgreSQL backup manually:

```bash
kubectl -n velero create -f - <<EOF
apiVersion: velero.io/v1
kind: Backup
metadata:
	name: postgres-manual-$(date +%Y%m%d%H%M)
	namespace: velero
spec:
	includedNamespaces:
		- prod
	snapshotVolumes: true
	defaultVolumesToFsBackup: true
	storageLocation: default
	ttl: 168h0m0s
EOF
```

Check backup status:

```bash
velero backup get
velero backup describe <backup-name> --details
```

Recommended for PostgreSQL consistency:
- add pre/post backup hooks to flush checkpoints
- or run a scheduled logical dump (`pg_dump`) in addition to volume backup