provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.server}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

provider "ignition" {
  version = "1.0.0"
}
