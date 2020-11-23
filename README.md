# Terraform module: vSphere VM

This module's original purpose is creation of Linux virtual machines from the existing template in vCenter.


## Assumptions
- Create any number of Linux VMs with similar configurations
- Ability to define list of VM names, ipv4 addresses, hosts and datastores*

*for now, datastores must be defined by using datastore id, you can find out one by using [govc](https://github.com/vmware/govmomi/tree/master/govc) tool from govmomi library.


## Requirements

This is not strict requirements and it may not work with other versions than tested ones.
Anyway. feel free to test by yourself, suggest addition of new functionality and contribute.

Module is tested with:
- Terraform version >= 0.13.5

Currently supports creation of Linux VM from existing template.

Terraform must be [installed](https://learn.hashicorp.com/tutorials/terraform/install-cli) on the machine, from which the module will be running.


## Inputs

Variables and their descriptions copied from variables.tf
```bash
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

```

## Outputs

No outputs for now.


## Usage example

Create main.tf file inside your root module's directory:
```bash
provider "vsphere" {
  user           = YOUR_VCENTER_USERNAME
  password       = YOUR_VCENTER_PASSWORD
  vsphere_server = YOUR_VCENTER_HOSTNAME_OR_IP

  allow_unverified_ssl = true
}

module "test-vms" {
  source = "github.com/caermeglaeddyv/terraform-vsphere-vm-module"

  vsphere_datacenter = YOUR_DATACENTER_NAME

  vsphere_datastores = [
    YOUR_DEFAULT_DATASTORE_NAME
  ]

  vsphere_hosts = [
    YOUR_IPV4_OF_ESXI1,
    YOUR_IPV4_OF_ESXI2,
    ...,
    YOUR_IPV4_OF_ESXIN
  ]

  vsphere_cluster = YOUR_CLUSTER_NAME

  vsphere_network = YOUR_NETWORK_NAME

  vm_template_name = YOUR_TEMPLATE_NAME

  vm_names = [
    YOUR_VM1_NAME,
    YOUR_VM2_NAME,
    ...,
    YOUR_VMN_NAME
  ]

  vm_folder = YOUR_VMS_FOLDER

  vm_num_cpus = YOUR_CPU_COUNT

  vm_cores_per_socket = YOUR_CORES_PER_SOCKET_COUNT

  vm_cpu_limit = YOUR_CPU_LIMIT

  vm_cpu_hot_add = YOUR_CPU_HOT_ADD

  vm_memory = YOUR_MEMORY_AMOUNT

  vm_memory_limit = YOUR_MEMORY_LIMIT

  vm_memory_hot_add = YOUR_MEMORY_HOT_ADD

  vm_scsi_controllers = YOUR_SCSI_CONTROLLER_COUNT

  vm_disks = {
    "disk0" = {
      unit_number      = YOUR_DISK_UNIT_NUMBER,
      disk_mode        = YOUR_DISK_MODE,
      size             = YOUR_DISK_SIZE,
      eagerly_scrub    = YOUR_DISK_EAGERLY_SCRUB,
      thin_provisioned = YOUR_DISK_THIN_PROVISIONING,
      datastore        = YOUR_DISK_DATASTORE_ID
    },
    ...,
    "diskN" = {
    ...
    }
  }

  vm_customize_time_zone = YOUR_TIME_ZONE

  vm_customize_domain = YOUR_DOMAIN_NAME

  vm_customize_ipv4_addresses = [
    YOUR_IPV4_OF_VM1,
    YOUR_IPV4_OF_VM2,
    ...,
    YOUR_IPV4_OF_VMN
  ]

  vm_customize_dns_server_list = YOUR_DNS_SERVER_ADDRESSES

  vm_customize_ipv4_gateway = YOUR_IPV4_DEFAULT_GATEWAY

}

```


## License

[Apache 2.0](https://github.com/caermeglaeddyv/ansible-role-rear/blob/dev/LICENSE)


## Authors

Copyright 2020 [caermeglaeddyv](https://github.com/caermeglaeddyv)
