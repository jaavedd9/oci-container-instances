variable "compartment_ocid" {
    description = "The OCI Compartment ocid"
    type        = string
}

variable "private_subnet_ocid" {
    description = "The OCI Private Subnet ocid"
    type        = string
}

#Use data to get ADs is better.
# variable "availability_domain" {
#     description = "The OCI Availability Domain"
#     type        = string
# }

variable "ci_name" {
    description = "The OCI Container Instance Name"
    type        = string
    default     = "CI_NAME"
}

variable "ci_name_bis" {
    description = "The OCI Container Instance Name"
    type        = string
    default     = "CI_NAME_BIS"
}

variable "ci_restart_policy" {
    description = "The OCI Container Instance Retsrat Policy"
    type        = string
    default     = "ALWAYS"
}

variable "ci_state" {
    description = "The OCI Container Instance State"
    type        = string
    default     = "ACTIVE"
}

variable "ci_shape" {
    description = "The OCI Container Instance Shape"
    type        = string
    default     = "CI.Standard.E4.Flex"
}

variable "ci_ocpus" {
    description = "The OCI Container Instance Ocpu Number"
    type        = number
    default     = 1
}

variable "ci_memory" {
    description = "The OCI Container Instance Memory GB Number"
    type        = number
    default     = 2
}

variable "ci_container_name" {
    description = "The OCI Container Name"
    type        = string
    default     = "CI_CONTAINER_NAME"
}



variable "ci_image_url" {
    description = "The OCI Container Image Url"
    type        = string
}

variable "ci_image_url_bis" {
    description = "The OCI Container Image Url"
    type        = string
}

variable "ci_count" {
    description = "The OCI Container Instance Count Number"
    type        = number
}

variable "ci_count_bis" {
    description = "The OCI Container Instance Count Number"
    type        = number
}


variable "ci_registry_secret" {
    description = "The OCI Vault Secret Id with username and password of OCI registry"
    type        = string
}

variable "ci_container_env_variables" {
  description = "OCI Container Environment Variables"
  type        = map(string)
  default     = {
    DATABASE_URL                 = null
    EGS_PRIVATE_KEY              = null
    ZATCA_BINARY_SECURITY_TOKEN  = null
    ZATCA_SECRET                 = null
    EGS_UUID                     = null
    DEVELOPMENT_MODE             = null
    DB_URL                       = null
    DB_USERNAME                  = null
    DB_PASSWORD                  = null
  }
}


#Get Availaibility Domains. We use only first AD. 
#TODO Later (Add logic for multi Ads Domain)
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.compartment_ocid}"
}

resource "oci_container_instances_container_instance" "this" {
  count = var.ci_count
  compartment_id           = var.compartment_ocid
  display_name             = var.ci_name
  availability_domain      = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")}"
  container_restart_policy = var.ci_restart_policy
  state                    = var.ci_state
  shape                    = var.ci_shape
  shape_config {
    ocpus         = var.ci_ocpus
    memory_in_gbs = var.ci_memory
  }
  vnics {
    display_name           = "nicnamenew${count.index}"
    hostname_label         = "hostnamenew${count.index}"
    subnet_id              = var.private_subnet_ocid
    skip_source_dest_check = false
    is_public_ip_assigned  = false
  }
  containers {
    display_name          = "${var.ci_container_name}${count.index}"
    environment_variables = {
          "DATABASE_URL" = "${var.ci_container_env_variables.DATABASE_URL}"
          "EGS_PRIVATE_KEY" = "${var.ci_container_env_variables.EGS_PRIVATE_KEY}"
          "ZATCA_BINARY_SECURITY_TOKEN" = "${var.ci_container_env_variables.ZATCA_BINARY_SECURITY_TOKEN}"
          "ZATCA_SECRET" = "${var.ci_container_env_variables.ZATCA_SECRET}"
          "EGS_UUID" = "${var.ci_container_env_variables.EGS_UUID}"
          "DEVELOPMENT_MODE" = "${var.ci_container_env_variables.DEVELOPMENT_MODE}"
          "DB_URL" = "${var.ci_container_env_variables.DB_URL}"
          "DB_USERNAME" = "${var.ci_container_env_variables.DB_USERNAME}"
          "DB_PASSWORD" = "${var.ci_container_env_variables.DB_PASSWORD}"
    }
    image_url             = var.ci_image_url
  }

  image_pull_secrets {
        #Required
        registry_endpoint = "fra.ocir.io"
        #secret_type = "BASIC"
        #username = base64encode("username")
        #password = base64encode("password")
        secret_type = "VAULT"
        secret_id = var.ci_registry_secret
    }
}

resource "oci_container_instances_container_instance" "thisbis" {
  count = var.ci_count_bis
  compartment_id           = var.compartment_ocid
  display_name             = var.ci_name_bis
  availability_domain      = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")}"
  container_restart_policy = var.ci_restart_policy
  state                    = var.ci_state
  shape                    = var.ci_shape
  shape_config {
    ocpus         = var.ci_ocpus
    memory_in_gbs = var.ci_memory
  }
  vnics {
    display_name           = "nicnamebis${count.index}"
    hostname_label         = "hostnamebis${count.index}"
    subnet_id              = var.private_subnet_ocid
    skip_source_dest_check = false
    is_public_ip_assigned  = false
  }
  containers {
    display_name          = "${var.ci_container_name}${count.index}"
    environment_variables = {
          "DATABASE_URL" = "${var.ci_container_env_variables.DATABASE_URL}"
          "EGS_PRIVATE_KEY" = "${var.ci_container_env_variables.EGS_PRIVATE_KEY}"
          "ZATCA_BINARY_SECURITY_TOKEN" = "${var.ci_container_env_variables.ZATCA_BINARY_SECURITY_TOKEN}"
          "ZATCA_SECRET" = "${var.ci_container_env_variables.ZATCA_SECRET}"
          "EGS_UUID" = "${var.ci_container_env_variables.EGS_UUID}"
          "DEVELOPMENT_MODE" = "${var.ci_container_env_variables.DEVELOPMENT_MODE}"
    }
    image_url             = var.ci_image_url_bis
  }

  image_pull_secrets {
        #Required
        registry_endpoint = "fra.ocir.io"
        #secret_type = "BASIC"
        #username = base64encode("username")
        #password = base64encode("password")
        secret_type = "VAULT"
        secret_id = var.ci_registry_secret
    }
}
