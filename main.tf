data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastores" {
  count         = length(var.vsphere_datastores)
  name          = var.vsphere_datastores[count.index]
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "hosts" {
  count         = length(var.vsphere_hosts)
  name          = var.vsphere_hosts[count.index]
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "linux-vm-template" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "linux-vm" {
  name = upper(var.vm_names[count.index])

  count          = length(var.vm_names)
  enable_logging = var.vm_enable_logging
  firmware       = var.vm_firmware
  folder         = var.vm_folder
  guest_id       = var.vm_guest_id

  num_cpus             = var.vm_num_cpus
  num_cores_per_socket = var.vm_cores_per_socket
  cpu_limit            = var.vm_cpu_limit
  cpu_hot_add_enabled  = var.vm_cpu_hot_add
  
  memory                 = var.vm_memory
  memory_limit           = var.vm_memory_limit
  memory_hot_add_enabled = var.vm_memory_hot_add

  cdrom {
    client_device = var.vm_cdrom_client_device
  }

  datastore_id          = data.vsphere_datastore.datastores[0].id
  resource_pool_id      = data.vsphere_compute_cluster.cluster.resource_pool_id
  host_system_id        = data.vsphere_host.hosts[count.index].id
  scsi_type             = var.vm_scsi_type
  scsi_controller_count = var.vm_scsi_controllers

  dynamic "disk" {
    for_each = var.vm_disks
    iterator = all_disks
    content {
      label            = terraform_disks.key
      unit_number      = lookup(all_disks.value, "unit_number", 0)
      disk_mode        = lookup(all_disks.value, "mode", "persistent")
      size             = lookup(all_disks.value, "size", 60)
      eagerly_scrub    = lookup(all_disks.value, "eagerly_scrub", false)
      thin_provisioned = lookup(all_disks.value, "thin_provisioned", true)
      datastore_id     = all_disks.value.datastore != "" ? lookup(all_disks.value, "datastore", null) : data.vsphere_datastore.datastores[0].id
    }
  }

  network_interface {
    adapter_type = var.vm_network_interface_adapter_type
    network_id   = data.vsphere_network.network.id
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.linux-vm-template.id

    customize {
      linux_options {
        host_name = var.vm_names[count.index]
        time_zone = var.vm_customize_time_zone
        domain    = var.vm_customize_domain
      }

      network_interface {
        ipv4_address = var.vm_customize_ipv4_addresses[count.index]
        ipv4_netmask = var.vm_customize_ipv4_netmask
      }

      dns_server_list = var.vm_customize_dns_server_list

      ipv4_gateway = var.vm_customize_ipv4_gateway
    }
  }
}
