// Copyright (c) 2017, 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "region" {
}

variable "compartment_ocid" {
}

variable "gateway_endpoint_type" {
  default = "PUBLIC"
}

variable "gateway_state" {
  default = "ACTIVE"
}

variable "public_apigateway_ocid" {
    description = "The OCI Public API Gateway ocid"
    type        = string
}

variable "public_subnet_ocid" {
    description = "The OCI Public Subnet ocid"
    type        = string
}

variable "deployment_path_prefix" {
  default = "/v2"
}

variable "deployment_specification_routes_backend_type" {
  default = "HTTP_BACKEND"
}

variable "deployment_specification_routes_backend_url" {
  default = null 
}

variable "deployment_specification_routes_methods" {
  default = ["GET"]
}

variable "deployment_specification_routes_path" {
  default = "/api/invoices/"
}

variable "deployment_state" {
  default = "ACTIVE"
}


variable "private_ip_lb" {
    description = "list of private ip for lb"
    type        = list
}

# provider "oci" {
#   tenancy_ocid     = var.tenancy_ocid
#   user_ocid        = var.user_ocid
#   fingerprint      = var.fingerprint
#   private_key_path = var.private_key_path
#   region           = var.region
# }

# resource "oci_core_subnet" "regional_subnet" {
#   cidr_block        = "10.0.1.0/24"
#   display_name      = "regionalSubnet"
#   dns_label         = "regionalsubnet"
#   compartment_id    = var.compartment_ocid
#   vcn_id            = oci_core_vcn.vcn1.id
#   security_list_ids = [oci_core_vcn.vcn1.default_security_list_id]
#   route_table_id    = oci_core_vcn.vcn1.default_route_table_id
#   dhcp_options_id   = oci_core_vcn.vcn1.default_dhcp_options_id
# }

# data "oci_identity_availability_domain" "ad" {
#   compartment_id = var.tenancy_ocid
#   ad_number      = 1
# }

# resource "oci_core_vcn" "vcn1" {
#   cidr_block     = "10.0.0.0/16"
#   compartment_id = var.compartment_ocid
#   display_name   = "exampleVCN"
#   dns_label      = "tfexamplevcn"
# }

resource "oci_apigateway_gateway" "test_gateway" {
  #Required
  compartment_id = var.compartment_ocid
  endpoint_type  = var.gateway_endpoint_type
  subnet_id      = var.public_subnet_ocid 
}

resource "oci_apigateway_deployment" "test_deployment" {
  #Required
  compartment_id = var.compartment_ocid
  gateway_id     = var.public_apigateway_ocid 
  path_prefix    = var.deployment_path_prefix

  specification {
    routes {
      #Required
      backend {
        #Required
        type = var.deployment_specification_routes_backend_type
        url  = var.deployment_specification_routes_backend_url
      }
      path = var.deployment_specification_routes_path
      methods = var.deployment_specification_routes_methods
    }
  }
}

data "oci_apigateway_gateways" "test_gateways" {
  #Required
  compartment_id = var.compartment_ocid

  #Optional
  state        = var.gateway_state
}

data "oci_apigateway_deployments" "test_deployments" {
  #Required
  compartment_id = var.compartment_ocid

  #Optional
  gateway_id  = var.public_apigateway_ocid 
  state   = var.deployment_state
}
