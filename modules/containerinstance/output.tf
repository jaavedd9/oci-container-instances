output "private_ips" {
  value =  "${oci_container_instances_container_instance.this.*.vnics.0.private_ip}"
}

output "private_ips_bis" {
  value =  "${oci_container_instances_container_instance.thisbis.*.vnics.0.private_ip}"
}
