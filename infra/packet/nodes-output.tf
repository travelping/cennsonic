output "Master_IPs_public" {
    value = "${join(", ", (packet_device.master.*.access_public_ipv4))}"
}

output "Master_IPs_private" {
    value = "${join(", ", (packet_device.master.*.access_private_ipv4))}"
}

output "Worker_IPs_public" {
    value = "${join(", ", (packet_device.worker.*.access_public_ipv4))}"
}

output "Worker_IPs_private" {
    value = "${join(", ", (packet_device.worker.*.access_private_ipv4))}"
}
