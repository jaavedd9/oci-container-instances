output "private_ips" {
  value =  module.containerinstance.private_ips
}

output "private_ips_bis" {
  value =  module.containerinstance.private_ips_bis
}

output "public_ip_lb" {
  value = module.loadbalancer.public_ip_lb
}

output "zones" {
  value = module.dns.zones
}

output "rrset" {
  value = module.dns.rrset
}