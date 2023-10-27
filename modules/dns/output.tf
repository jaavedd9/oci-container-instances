output "zones" {
  value = data.oci_dns_zones.zs.zones
}

output "records" {
  value = data.oci_dns_records.rs.records
}