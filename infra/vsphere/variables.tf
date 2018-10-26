# To avoid keeping sensitive or personalized information here
# the "TF_VAR_vsphere_user" and "TF_VAR_vsphere_password" environment variables
# could be set to define "vsphere_user" and "vsphere_password" Terraform ones

variable "vsphere_user" {}
variable "vsphere_password" {}

variable "server" {
  default = "vsphere.tpmd-01.eu.tpip.net"
}
variable "datacenter" {
  default = "tpmd-01.eu.tpip.net"
}
variable "resource_pool" {
  default = "its-01"
}
variable "datastore" {
  default = "nas-03-hdd-01"
}
variable "network" {
  default = "TPO Lab VLAN 16"
}
