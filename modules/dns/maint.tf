variable "compartment_ocid" {
    description = "The OCI Compartment ocid"
    type        = string
}

variable "zone_name" {
    description = "The OCI Zone Name"
    type        = string
}

variable "lb_ip_address" {
    description = "The OCI LB CI IP Address"
    type        = string
}

resource "oci_dns_zone" "zone1" {
  compartment_id = var.compartment_ocid
  name           = var.zone_name
  zone_type      = "PRIMARY"
}

data "oci_dns_zones" "zs" {
  compartment_id = var.compartment_ocid
  name_contains  = "example"
  state          = "ACTIVE"
  zone_type      = "PRIMARY"
  sort_by        = "name" # name|zoneType|timeCreated
  sort_order     = "DESC" # ASC|DESC
}

resource "oci_dns_record" "record-a" {
  zone_name_or_id = oci_dns_zone.zone1.name
  domain          = oci_dns_zone.zone1.name
  rtype           = "A"
  rdata           = var.lb_ip_address
  ttl             = 3600
}