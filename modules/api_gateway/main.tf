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

variable "domain_url" {
  default = ""
}

variable "deployment_specification_routes_backend_type" {
  default = "HTTP_BACKEND"
}

variable "deployment_specification_routes_backend_base_url" {
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

# resource "oci_apigateway_gateway" "test_gateway" {
#   #Required

#   display_name   = var.api_gateway_name
#   compartment_id = var.compartment_ocid
#   endpoint_type  = var.gateway_endpoint_type
#   subnet_id      = var.public_subnet_ocid 
# }

resource "oci_apigateway_deployment" "test_env_deployment" {
 # https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/apigateway_deployment   

  #Required
  compartment_id = var.compartment_ocid
  gateway_id     = var.public_apigateway_ocid 
  path_prefix    = var.deployment_path_prefix


  specification {

    request_policies {
     authentication  {
        type          = "JWT_AUTHENTICATION"
        issuers       = ["https://identity.oraclecloud.com/"]
         audiences = ["invoicing-apis"]
         token_auth_scheme= "Bearer"
         token_header ="Authorization"
         verify_claims {
            is_required = false
            key   = "can_access_invoicing_app_claim"
            values = ["yes"]
        }
        # subject_claims = ["sub"]
         public_keys {
             type = "REMOTE_JWKS"
             uri = "${var.domain_url}/admin/v1/SigningCert/jwk"
             max_cache_duration_in_hours = 3
         } 
      }

    cors {
        # allowed_origins = ["https://coral-app-5d4ev.ondigitalocean.app"]
        # allow all origings for testing
        allowed_origins = ["*"]
        allowed_methods = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
        # note cors works only when Authorization header is allowed
        allowed_headers = ["Content-Type", "Authorization"]
        # exposed_headers = ["Access-Control-Allow-Origin"]

      }
    }

    ## sellers
    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
        url = "${var.deployment_specification_routes_backend_base_url}/sellers/"
      }
      path = "/api/sellers/" 
        methods = ["GET", "POST", "PUT"] 
    }

   ## buyers
    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/buyers/"
      }
      path = "/api/buyers/" 
        methods = ["GET", "POST", "PUT"] 
    }

    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/buyers/mybuyers/"
      }
      path = "/api/buyers/mybuyers/" 
        methods = ["GET", "POST"] 
    }

    ## invoices
    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/invoices/"
      }
      path = "/api/invoices/" 
        methods = ["GET", "POST"] 
    }

    ## invoice search
    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/invoices/searches/"
      }
      path = "/api/invoices/searches/" 
        methods = ["GET", "POST"] 
    }

    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/invoices/searches/index-filters/"
      }
      path = "/api/invoices/searches/index-filters/" 
        methods = ["GET", "POST"] 
    }

    ## certificates
    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/certificates/csrs/"
      }
        path = "/api/certificates/csrs/" 
        methods = ["POST"] 
    }

    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/certificates/csids/"
      }
      path = "/api/certificates/csids/"
        methods = ["POST"] 
    }

    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/certificates/pcsids/"
      }
        path = "/api/certificates/pcsids/" 
        methods = ["POST"] 
    }

    ## users

    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/users/"
      }
      path = "/api/users/" 
        methods = ["GET", "POST"] 
    }

    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/users/roles/"
      }
      path = "/api/users/roles/" 
        methods = ["GET", "POST"] 
    }

    routes {
      backend {
        type = var.deployment_specification_routes_backend_type
          url = "${var.deployment_specification_routes_backend_base_url}/users/userinfo/"
      }
      path = "/api/users/userinfo/" 
        methods = ["GET", "POST"] 
    }


  }
}

