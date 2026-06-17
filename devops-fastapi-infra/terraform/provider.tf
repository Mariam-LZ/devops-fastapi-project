terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.73"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://62.210.91.134:8006"
  api_token = var.api_token
  insecure  = true

  tmp_dir = "/var/tmp"
}
