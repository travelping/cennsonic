data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.resource_pool}.${var.datacenter}/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "coreos_production_vmware_ova"
  #name          = "tmpl.coreos.cennsonic.${var.datacenter}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
