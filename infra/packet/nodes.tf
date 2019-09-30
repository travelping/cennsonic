variable "packet_auth_token" {}
variable "packet_project_id" {}

provider "packet" {
    auth_token = "${var.packet_auth_token}"
}

variable "cluster" {
    default = "cennsonic.example.net"
}

resource "packet_device" "master" {
    count = 1
    hostname = "master-0${count.index + 1}.${var.cluster}"
    facilities = ["ams1"]
    billing_cycle = "hourly"
    plan = "baremetal_0"
    operating_system = "ubuntu_18_04"
    project_id = "${var.packet_project_id}"

    provisioner "local-exec" {
      command = "echo \"${self.hostname} ansible_ssh_host=${self.access_public_ipv4} ip=${self.access_private_ipv4}\" >> hosts.ini"
    }
}

resource "packet_device" "worker" {
    count = 2
    hostname = "worker-0${count.index + 1}.${var.cluster}"
    facilities = ["ams1"]
    billing_cycle = "hourly"
    plan = "c1.small.x86"
    operating_system = "ubuntu_18_04"
    project_id = "${var.packet_project_id}"
    public_ipv4_subnet_size = "30"

    provisioner "local-exec" {
      command = "echo \"${self.hostname} ansible_ssh_host=${self.access_public_ipv4} ip=${self.access_private_ipv4}\" >> hosts.ini"
    }
}
