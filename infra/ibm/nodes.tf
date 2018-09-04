provider "ibm" {}

data "ibm_compute_ssh_key" "public_key" {
    label = "aal"
}

resource "ibm_compute_vm_instance" "master-nfv-k8s-example-net" {
    count = 0
    hostname = "master-0${count.index + 1}"
    domain = "nfv-k8s.example.net"
    os_reference_code = "UBUNTU_16_64"
    datacenter = "fra02"
    network_speed = 100
    cores = 2
    memory = 4096
    disks = [25]
    hourly_billing = true
    ssh_key_ids = ["${data.ibm_compute_ssh_key.public_key.id}"]
    tags = ["master", "nfv-k8s", "fra02"]
}

resource "ibm_compute_vm_instance" "worker-nfv-k8s-example-net" {
    count = 0
    hostname = "worker-0${count.index + 1}"
    domain = "nfv-k8s.example.net"
    os_reference_code = "UBUNTU_16_64"
    datacenter = "fra02"
    network_speed = 100
    cores = 4
    memory = 8192
    disks = [100]
    hourly_billing = true
    ssh_key_ids = ["${data.ibm_compute_ssh_key.public_key.id}"]
    tags = ["worker", "nfv-k8s", "fra02"]
}
