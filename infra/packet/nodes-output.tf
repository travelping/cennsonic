output "Master IPs public" {
    value = "${join(", ", (packet_device.master.*.access_public_ipv4))}"
}

output "Master IPs private" {
    value = "${join(", ", (packet_device.master.*.access_private_ipv4))}"
}

output "Worker IPs public" {
    value = "${join(", ", (packet_device.worker.*.access_public_ipv4))}"
}

output "Worker IPs private" {
    value = "${join(", ", (packet_device.worker.*.access_private_ipv4))}"
}
