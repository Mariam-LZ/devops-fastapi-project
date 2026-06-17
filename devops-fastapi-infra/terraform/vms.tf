# IP addresses are provisional and may be adjusted
# depending on the available lab network range.

locals {
  vms = {
    master-1 = {
      role      = "master"
      cores     = 4
      memory    = 8192
      disk_size = "100"
      ip        = "192.168.1.110"
    }

    master-2 = {
      role      = "master"
      cores     = 4
      memory    = 8192
      disk_size = "100"
      ip        = "192.168.1.111"
    }

    master-3 = {
      role      = "master"
      cores     = 4
      memory    = 8192
      disk_size = "100"
      ip        = "192.168.1.112"
    }

    worker-1 = {
      role      = "worker"
      cores     = 4
      memory    = 12288
      disk_size = "100"
      ip        = "192.168.1.120"
    }

    worker-2 = {
      role      = "worker"
      cores     = 4
      memory    = 12288
      disk_size = "100"
      ip        = "192.168.1.121"
    }

    worker-3 = {
      role      = "worker"
      cores     = 4
      memory    = 12288
      disk_size = "100"
      ip        = "192.168.1.122"
    }

    services-1 = {
      role      = "services"
      cores     = 4
      memory    = 12288
      disk_size = "150"
      ip        = "192.168.1.140"
    }
  }
}
