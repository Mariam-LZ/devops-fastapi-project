# Generate the Ansible inventory directly from Terraform VM outputs.
# This keeps infrastructure provisioning and configuration synchronized.
resource "local_file" "ansible_inventory" {

  content = templatefile("${path.module}/templates/inventory.tpl", {
    master_ips = [
      for name, vm in local.vms : vm.ip
      if vm.role == "master"
    ]

    worker_ips = [
      for name, vm in local.vms : vm.ip
      if vm.role == "worker"
    ]

    services_ip = [
      for name, vm in local.vms : vm.ip
      if vm.role == "services"
    ][0]

    ssh_user              = var.vm_user
    jump_user             = var.jump_user
    proxmox_host          = var.proxmox_host
    jump_private_key_file = var.jump_private_key_file
    ssh_private_key_file  = var.ssh_private_key_file
  })

  filename = "${path.module}/../ansible/inventory/hosts.ini"
}

# Export shared infrastructure values for Ansible group_vars.
# Avoids duplicating cluster/network configuration manually.
resource "local_file" "ansible_vars" {

  content = templatefile("${path.module}/templates/generated-vars.tpl", {
    master_ips = [
      for name, vm in local.vms : vm.ip
      if vm.role == "master"
    ]

    worker_ips = [
      for name, vm in local.vms : vm.ip
      if vm.role == "worker"
    ]

    kube_api_vip = var.kube_api_vip
    domain       = var.domain
    acme_email   = var.acme_email
  })

  filename             = "${path.module}/../ansible/inventory/group_vars/all/generated.yml"
  directory_permission = "0755"
  file_permission      = "0644"
}