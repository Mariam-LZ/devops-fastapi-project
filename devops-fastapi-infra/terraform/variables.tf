variable "api_token" {
  type        = string
  sensitive   = true
  description = "Proxmox API token"
}

variable "target_node" {
  type    = string
  default = "mar26-bootcamp-devops-fastapi"
}

variable "template_vm_id" {
  type    = number
  default = 1000
}

variable "datastore_id" {
  type    = string
  default = "local"
}

variable "network_bridge" {
  type    = string
  default = "vmbr1"
}

variable "gateway" {
  type    = string
  default = "192.168.1.1"
}

variable "vm_user" {
  type    = string
  default = "debian"
}

variable "proxmox_host" {
  type        = string
  description = "Proxmox host used for SSH ProxyJump"
  default     = "62.210.91.134"
}

variable "jump_user" {
  type        = string
  default     = "adminops"
  description = "SSH user used for ProxyJump connection"
}

variable "jump_private_key_file" {
  type        = string
  default     = "~/.ssh/proxmox_ed25519"
  description = "SSH private key used for ProxyJump connection"
}

variable "ssh_keys" {
  type = list(string)
}

variable "ssh_private_key_file" {
  type        = string
  default     = "~/.ssh/ansiblehost"
  description = "SSH private key used by Ansible to connect to VMs"
}

variable "kube_api_vip" {
  description = "Virtual IP used for the Kubernetes API load balancer"
  type        = string
  default     = "192.168.1.100"
}

variable "domain" {
  description = "Base domain used by Kubernetes platform components"
  type        = string
}

variable "acme_email" {
  description = "Email used for ACME certificates"
  type        = string
}