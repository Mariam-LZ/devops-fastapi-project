output "vm_summary" {
  value = {
    for name, config in local.vms :
    name => {
      role   = config.role
      ip     = config.ip
      cores  = config.cores
      memory = config.memory
      disk   = config.disk_size
      vm_id  = proxmox_virtual_environment_vm.vm[name].vm_id
    }
  }
}