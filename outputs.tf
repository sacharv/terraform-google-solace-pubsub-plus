# TF outputs
output "solace_instance_id" {
  value = "${join(",", google_compute_instance.solace-instance.*.instance_id )}"
}

output "solace_public_ip_addresses" {
  value = "${join(",", google_compute_instance.solace-instance.*.network_interface.0.access_config.0.assigned_nat_ip )}"
}

output "solace_private_ip_addresses" {
  value = "${join(",", google_compute_instance.solace-instance.*.network_interface.0.address )}"
}
