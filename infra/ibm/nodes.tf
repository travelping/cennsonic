provider "ibm" {}

data "ibm_compute_ssh_key" "public_key" {
    label = "aal"
}

resource "ibm_compute_vm_instance" "master-cennsonic-example-net" {
    count = 0
    hostname = "master-0${count.index + 1}"
    domain = "cennsonic.example.net"
    os_reference_code = "UBUNTU_16_64"
    datacenter = "fra02"
    network_speed = 100
    cores = 2
    memory = 4096
    disks = [25]
    ipv6_enabled = true
    hourly_billing = true
    ssh_key_ids = ["${data.ibm_compute_ssh_key.public_key.id}"]
    tags = ["master", "cennsonic", "fra02"]

    provisioner "local-exec" {
        command = "echo \"${self.hostname} ansible_ssh_host=${self.ipv4_address} ip=${self.ipv4_address_private}\" >> hosts.ini"
    }
}

resource "ibm_compute_vm_instance" "worker-cennsonic-example-net" {
    count = 0
    hostname = "worker-0${count.index + 1}"
    domain = "cennsonic.example.net"
    os_reference_code = "UBUNTU_16_64"
    datacenter = "fra02"
    network_speed = 100
    cores = 4
    memory = 8192
    disks = [100]
    ipv6_enabled = true
    hourly_billing = true
    ssh_key_ids = ["${data.ibm_compute_ssh_key.public_key.id}"]
    tags = ["worker", "cennsonic", "fra02"]

    provisioner "local-exec" {
        command = "echo \"${self.hostname} ansible_ssh_host=${self.ipv4_address} ip=${self.ipv4_address_private}\" >> hosts.ini"
    }
}

#data "ibm_compute_vm_instance" "worker-cennsonic-example-net" {
#    count = 0
#    hostname = "worker-0${count.index + 1}"
#    domain = "cennsonic.example.net"
#    most_recent = true
#}
