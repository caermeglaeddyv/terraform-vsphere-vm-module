variable "vsphere_datacenter" {
  description = "Name of the datacenter in vCenter environment to deploy new VMs"
  type = string
}

variable "vsphere_datastores" {
  description = "List of datastores to use while disk createion, currently only first one is used as default one"
  type = list(string)
}

variable "vsphere_hosts" {
  description = "List of ESXi hosts where VMs will be deployed one by one"
  type = list(string)
}

variable "vsphere_cluster" {
  description = "Cluster name to create compute resources in"
  type = string
}

variable "vsphere_network" {
  description = "Network name to attach NIC to"
  type = string
}

variable "vm_template_name" {
  description = "Name of the existing VM template which will be used to clone new VMs from"
  type    = string
}

variable "vm_names" {
  description = "List of new VM names which will be created from the existing template"
  type = list(string)
}

variable "vm_enable_logging" {
  description = "Whether to enable logging of VM events or not"
  type    = bool
  default = true
}

variable "vm_firmware" {
  description = "Firmware type of newly created VMs"
  type    = string
  default = "bios"
}

variable "vm_folder" {
  description = "vCenter folder where newly created VMs will be placed"
  type = string
}

variable "vm_guest_id" {
  description = "Operating system type defined via guest ID, which values can be found here - https://code.vmware.com/apis/358/doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html"
  type    = string
  default = "centos7_64Guest"
}

variable "vm_num_cpus" {
  description = "Number of CPUs assigned to each VM"
  type    = number
  default = 1
}

variable "vm_cores_per_socket" {
  description = "Number which represents CPU count distributed on every socket"
  type    = number
  default = 1
}

variable "vm_cpu_limit" {
  description = "Maximum amount of CPU in MHz which can be consumed by VM"
  type = string
}

variable "vm_cpu_hot_add" {
  description = "Ability to add CPUs while VM is in running state"
  type    = bool
  default = false
}

variable "vm_memory" {
  description = "Amount of memory in MB which will be assigned to every VM"
  type    = number
  default = 2048
}

variable "vm_memory_limit" {
  description = "Maximum amount of memory in MB which can be consumed by VM"
  type    = number
  default = 2048
}

variable "vm_memory_hot_add" {
  description = "Ability to add memory while VM is in running state"
  type    = bool
  default = false
}

variable "vm_cdrom_client_device" {
  description = "Whether cdrom should be backed by remote client device or not"
  type    = bool
  default = true
}

variable "vm_scsi_type" {
description = "The type of SCSI bus which will be added to the VMs"
  type    = string
  default = "pvscsi"
}

variable "vm_scsi_controllers" {
  description = "Number of SCSI controllers added to each VM"
  type    = number
  default = 1
}

variable "vm_disks" {
  description = "Object which represents VM disks will be added to each newly created VM, including the ones from the template, where the key of each object will be the label of the disk in format 'diskN' where N is the number starting from 0"
  type    = map(object({
    # The number of the disk on the storage bus starting from 0 (maximum 15 on each SCSI controller)
    unit_number      = number
    # The mode of the disk
    disk_mode        = string
    # The size of disk in GB
    size             = number
    # Whether disk space must be zeroed or not
    eagerly_scrub    = bool
    # Whether disk space will be allocated on as-needed basis or not
    thin_provisioned = bool
    # A managed object reference ID to the datastore for disk,can be found by using govc tool - https://github.com/vmware/govmomi/tree/master/govc
    datastore        = string
  }))
}

variable "vm_network_interface_adapter_type" {
  description = "Virtual NIC's adapter type"
  type = string
  default = "vmxnet3"
}

variable "vm_customize_time_zone" {
  description = "Time zone which will be assigned to machine"
  type = string
  default = "UTC"
}

variable "vm_customize_domain" {
  description = "Domain name which will be assigned to machine"
  type = string
  default = "example.internal"
}

variable "vm_customize_ipv4_addresses" {
  description = "List of ipv4 addresses which will be assigned to VMs one by one"
  type = list(string)
}

variable "vm_customize_ipv4_netmask" {
  description = "Subnet mask to set on machine's NIC"
  type = number
  default = 24
}

variable "vm_customize_dns_server_list" {
  description = "List of DNS server addresses assigned to the machine"
  type = list(string)
  default = ["8.8.8.8", "8.8.4.4"]
}

variable "vm_customize_ipv4_gateway" {
  description = "Default gateway which will be set inside machine"
  type = string
}
