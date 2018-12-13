variable "cluster" {
  default = "cennsonic-01"
}

resource "vsphere_folder" "folder" {
  type          = "vm"
  path          = "${var.cluster}.${var.datacenter}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

variable "name" {
  default = {
    "0" = "master-01"
    "1" = "master-02"
    "2" = "master-03"
    "3" = "worker-01"
    "4" = "worker-02"
    "5" = "worker-03"
    "6" = "worker-04"
  }
}

variable "num_cpus" {
  default = {
    "master-01" = 2
    "master-02" = 2
    "master-03" = 2
    "worker-01" = 4
    "worker-02" = 4
    "worker-03" = 4
    "worker-04" = 4
  }
}
variable "memory" {
  default = {
    "master-01" = 2048
    "master-02" = 2048
    "master-03" = 2048
    "worker-01" = 4096
    "worker-02" = 4096
    "worker-03" = 4096
    "worker-04" = 4096
  }
}
variable "disk_size" {
  default = {
    "master-01" = 30
    "master-02" = 30
    "master-03" = 30
    "worker-01" = 50
    "worker-02" = 50
    "worker-03" = 50
    "worker-04" = 50
  }
}
variable "ipv4_address" {
  default = {
    "master-01" = "172.20.16.141"
    "master-02" = "172.20.16.142"
    "master-03" = "172.20.16.143"
    "worker-01" = "172.20.16.144"
    "worker-02" = "172.20.16.145"
    "worker-03" = "172.20.16.146"
    "worker-04" = "172.20.16.150"
  }
}
variable "ipv4_netmask" {
  default = 24
}
variable "ipv4_gateway" {
  default = "172.20.16.1"
}
#variable "dns_server_list" {
#  default = ["8.8.8.8"]
#}
variable "dns_server" {
  default = "8.8.8.8"
}
variable "iface" {
  default = "ens192"
}

data "http" "aalferov_keys" { url = "https://github.com/aialferov.keys" }

data "ignition_user" "core" {
  name = "core"
  # generate with "openssl rand -base64 8 | openssl passwd -1 -stdin"
  password_hash = "$1$4HeHmKEH$tiRQnP122R228tcmLrhbQ1"
  ssh_authorized_keys = ["${chomp(data.http.aalferov_keys.body)}"]
}

data "ignition_file" "ip_vs" {
  count = "${length(var.name)}"

  filesystem = "root"
  path = "/etc/modules-load.d/ip_vs.conf"
  mode = 420
  content { content = "ip_vs" }
}

data "ignition_file" "ip_vs_rr" {
  count = "${length(var.name)}"

  filesystem = "root"
  path = "/etc/modules-load.d/ip_vs_rr.conf"
  mode = 420
  content { content = "ip_vs_rr" }
}

data "ignition_file" "ip_vs_wrr" {
  count = "${length(var.name)}"

  filesystem = "root"
  path = "/etc/modules-load.d/ip_vs_wrr.conf"
  mode = 420
  content { content = "ip_vs_wrr" }
}

data "ignition_file" "ip_vs_sh" {
  count = "${length(var.name)}"

  filesystem = "root"
  path = "/etc/modules-load.d/ip_vs_sh.conf"
  mode = 420
  content { content = "ip_vs_sh" }
}

data "ignition_file" "hostname" {
  count = "${length(var.name)}"

  filesystem = "root"
  path = "/etc/hostname"
  mode = 420
  content {
    content = <<EOF
${lookup(var.name, count.index)}.${var.cluster}.${var.datacenter}
EOF
  }
}

data "ignition_networkd_unit" "iface" {
  count = "${length(var.name)}"

  name = "00-${var.iface}.network"
  content = <<EOF
[Match]
Name=${var.iface}
[Network]
DNS=${var.dns_server}
Address=${var.ipv4_address["${lookup(var.name, count.index)}"]}/${var.ipv4_netmask}
Gateway=${var.ipv4_gateway}
EOF
}

data "ignition_config" "config" {
  count = "${length(var.name)}"

  files = ["${element(data.ignition_file.ip_vs.*.id, count.index)}"]
  files = ["${element(data.ignition_file.ip_vs_rr.*.id, count.index)}"]
  files = ["${element(data.ignition_file.ip_vs_wrr.*.id, count.index)}"]
  files = ["${element(data.ignition_file.ip_vs_sh.*.id, count.index)}"]
  files = ["${element(data.ignition_file.hostname.*.id, count.index)}"]
  networkd = ["${element(data.ignition_networkd_unit.iface.*.id, count.index)}"]
  users = ["${data.ignition_user.core.id}"]
}

resource "vsphere_virtual_machine" "node" {
  count = "${length(var.name)}"

  name = "${lookup(var.name, count.index)}.${var.cluster}.${var.datacenter}"
  folder = "${vsphere_folder.folder.path}"

  datastore_id = "${data.vsphere_datastore.datastore.id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"

  num_cpus = "${var.num_cpus["${lookup(var.name, count.index)}"]}"
  memory = "${var.memory["${lookup(var.name, count.index)}"]}"

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type =
      "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label = "disk0"
    #size = "${data.vsphere_virtual_machine.template.disks.0.size}"
    size = "${var.disk_size["${lookup(var.name, count.index)}"]}"

    eagerly_scrub =
      "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned =
      "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    #customize {
    #  linux_options {
    #    host_name = "${lookup(var.name, count.index)}"
    #    domain = "${var.cluster}.${var.datacenter}"
    #  }

    #  #network_interface {
    #  #  ipv4_address = "${var.ipv4_address["${lookup(var.name, count.index)}"]}"
    #  #  ipv4_netmask = "${var.ipv4_netmask}"
    #  #}

    #  #ipv4_gateway = "${var.ipv4_gateway}"

    #  #dns_server_list = "${var.dns_server_list}"
    #  #dns_suffix_list = 
    #  #    ["${lookup(var.name, count.index)}.${var.cluster}.${var.datacenter}"]
    #}
  }

  extra_config {
    guestinfo.coreos.config.data.encoding = "base64"
    guestinfo.coreos.config.data =
      "${base64encode(element(data.ignition_config.config.*.rendered, count.index))}"
  }
}
