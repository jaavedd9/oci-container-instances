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
    AES_MASTER_KEY               = null
    DEVELOPMENT_MODE             = null
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
        "AES_MASTER_KEY" = "${var.ci_container_env_variables.AES_MASTER_KEY}"
        "DEVELOPMENT_MODE" = "${var.ci_container_env_variables.DEVELOPMENT_MODE}"
        "OPENSEARCH_LOG_ENABLED"="${var.ci_container_env_variables.OPENSEARCH_LOG_ENABLED}"
        "OPENSEARCH_LOG_DB_URL"="${var.ci_container_env_variables.OPENSEARCH_LOG_DB_URL}"
        "OPENSEARCH_LOG_USERNAME"="${var.ci_container_env_variables.OPENSEARCH_LOG_USERNAME}"
        "OPENSEARCH_LOG_PASSWORD"="${var.ci_container_env_variables.OPENSEARCH_LOG_PASSWORD}"
        "OPENSEARCH_LOG_INDEX"="${var.ci_container_env_variables.OPENSEARCH_LOG_INDEX}"
        "DJANGO_OPENSEARCH_LOG_LEVEL"="${var.ci_container_env_variables.DJANGO_OPENSEARCH_LOG_LEVEL}"
        "DJANGO_LOG_LEVEL"="${var.ci_container_env_variables.DJANGO_LOG_LEVEL}"
        "APP_ENV"="${var.ci_container_env_variables.APP_ENV}"
        "SENTRY_DSN"="${var.ci_container_env_variables.SENTRY_DSN}"
        "OPENSEARCH_SEARCH_DB_URL"="${var.ci_container_env_variables.OPENSEARCH_SEARCH_DB_URL}"

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
          "AES_MASTER_KEY" = "${var.ci_container_env_variables.AES_MASTER_KEY}"
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
