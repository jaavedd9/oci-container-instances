terraform {
  required_providers {
    oci = {
      version = "~> 4.112.0"
    }
  }

  #OCI Terraform Stack does not support last version
  #required_version = "~> 1.3.6"
  #OCI Terraform Stack use this version
  required_version = "~> 1.2.9"
}

module "containerinstance" {
  source  = "./modules/containerinstance"

  compartment_ocid  = var.compartment_ocid
  private_subnet_ocid = var.private_subnet_ocid
  ci_name = var.ci_name
  ci_restart_policy = var.ci_restart_policy
  ci_state = var.ci_state
  ci_shape = var.ci_shape
  ci_ocpus = var.ci_ocpus
  ci_memory = var.ci_memory
  ci_container_name = var.ci_container_name
  ci_image_url = var.ci_image_url
  ci_image_url_bis = var.ci_image_url_bis
  ci_registry_secret = var.ci_registry_secret
  ci_count = var.ci_count
  ci_count_bis = var.ci_count_bis
  ci_container_env_variables = var.ci_container_env_variables
}

module "loadbalancer" {
  source  = "./modules/loadbalancer"

  compartment_ocid  = var.compartment_ocid
  private_subnet_ocid = var.private_subnet_ocid
  public_subnet_ocid = var.public_subnet_ocid
  load_balancer_shape_details_minimum_bandwidth_in_mbps = var.load_balancer_shape_details_minimum_bandwidth_in_mbps
  load_balancer_shape_details_maximum_bandwidth_in_mbps = var.load_balancer_shape_details_maximum_bandwidth_in_mbps
  private_ips = concat(module.containerinstance.private_ips, module.containerinstance.private_ips_bis)
  lb_name = var.lb_name
  lb_checker_health_port = var.lb_checker_health_port
  lb_checker_url_path = var.lb_checker_url_path
  lb_backend_port = var.lb_backend_port
  lb_listener_port = var.lb_listener_port
}


module "api_gateway" {
  source  = "./modules/api_gateway"
   
  compartment_ocid  = var.compartment_ocid
  public_subnet_ocid = var.public_subnet_ocid
  region = var.region
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint = var.fingerprint
  domain_url = var.domain_url
  public_apigateway_ocid = var.public_apigateway_ocid
  private_ip_lb = module.loadbalancer.private_ip_lb
  deployment_specification_routes_backend_base_url =  "http://${module.loadbalancer.private_ip_lb[0].ip_address}/api"
}


module "opensearch" {
    source  = "./modules/opensearch"
    root_compartment_ocid  = var.root_compartment_ocid
    compartment_ocid  = var.compartment_ocid
    superadmin_ocid = var.superadmin_ocid
    vcn_compartment_ocid = var.vcn_compartment_ocid
    vcn_ocid = var.vcn_ocid
    public_subnet_ocid = var.public_subnet_ocid
    opensearch_security_master_user_name = var.opensearch_security_master_user_name
    opensearch_security_master_user_password_hash = var.opensearch_security_master_user_password_hash

}


module "objectstorage" {
    source = "./modules/objectstorage"
    compartment_ocid  = var.compartment_ocid
    compartment_name = var.compartment_name
    root_compartment_ocid  = var.root_compartment_ocid
    objectstorage_namespace = var.objectstorage_namespace
    objectstorage_bucket_name = var.objectstorage_bucket_name

}
