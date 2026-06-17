resource "proxmox_virtual_environment_vm" "vm" {
  for_each = local.vms

  name      = each.key
  node_name = var.target_node

  # Create each VM from the shared Proxmox template.
  clone {
    vm_id = var.template_vm_id
  }

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory
  }

  # QEMU guest agent allows Terraform/Proxmox to retrieve VM state and IP data.
  agent {
    enabled = true
  }

  timeout_start_vm = 300

  network_device {
    model  = "virtio"
    bridge = var.network_bridge
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = each.value.disk_size
  }

  initialization {
    datastore_id = var.datastore_id

    dns {
      servers = ["8.8.8.8", "8.8.4.4"]
    }

    user_account {
      username = var.vm_user
      keys     = var.ssh_keys
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.gateway
      }
    }
  }

  lifecycle {
    # Prevent Terraform from recreating or modifying VM network devices
    # when Proxmox returns provider-side network metadata changes.
    ignore_changes = [
      network_device
    ]
  }
}