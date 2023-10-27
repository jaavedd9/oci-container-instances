output "zones" {
  value = data.oci_dns_zones.zs.zones
}

output "rrset" {
  value = data.oci_dns_rrset.test_rrset
}