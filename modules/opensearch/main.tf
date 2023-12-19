variable "compartment_ocid" {
  // Description or default value (if any) for compartment_ocid
}


variable "root_compartment_ocid" {
  // Description or default value (if any) for compartment_ocid
}


variable "superadmin_ocid" {
  // Description or default value (if any) for superadmin_ocid
}

variable "public_subnet_ocid" {
  // Description or default value (if any) for public_subnet_ocid
}

variable "vcn_ocid" {
  // Description or default value (if any) for vcn_ocid
}


variable "vcn_compartment_ocid" {
  // Description or default value (if any) for vcn_compartment_ocid
}


variable "opensearch_security_master_user_name" {
  // Description or default value (if any) for opensearch_security_master_user_name
}

variable "opensearch_security_master_user_password_hash" {
  // Description or default value (if any) for opensearch_security_master_user_password_hash
}


variable "opensearch_group_name" {
    description = "opensearch_group_name"
    type        = string
    default     = "SearchOpenSearchAdmins"
}


resource "oci_identity_group" "opensearch_admins" {
  compartment_id = var.root_compartment_ocid
    name = var.opensearch_group_name
    description = "opensearch group"
}

resource "oci_identity_user_group_membership" "opensearch_admin_membership" {
  user_id = var.superadmin_ocid
  group_id = oci_identity_group.opensearch_admins.id
  // Removed the unsupported 'description' attribute
}

resource "oci_identity_policy" "opensearch_policy" {
    # this policy requires resources from other compartments, it should be in root compartment
  compartment_id = var.root_compartment_ocid
  name = "opensearch_policy"
  description = "opensearch_policy"
  statements = [
    "allow service opensearch to manage vcns in compartment Network",
    "allow service opensearch to manage vnics in compartment Network",
    "allow service opensearch to use subnets in compartment Network",
    "allow service opensearch to use network-security-groups in compartment Network",
    "allow service opensearch to {VNIC_CREATE} in compartment Network",
    "allow group ${var.opensearch_group_name} to manage opensearch-family in compartment Dev",
  ]
}


# create terraform configuration to create opensearch cluster to index logs from containers instance
# the opensearch dashboard should be available on the public subnet


resource "oci_opensearch_opensearch_cluster" "test_cluster" {
  # Required parameters
  compartment_id = var.compartment_ocid
  display_name   = "invoicing-app-cluster"
  software_version = "2.8.0"

  # Network configuration
    subnet_id = var.public_subnet_ocid 
    subnet_compartment_id = var.vcn_compartment_ocid
	vcn_compartment_id = var.vcn_compartment_ocid 
    vcn_id = var.vcn_ocid

  # connection  
    security_master_user_name = var.opensearch_security_master_user_name 
    security_master_user_password_hash = var.opensearch_security_master_user_password_hash 
    # security_mode = "MASTER_USER_AUTHENTICATION"

  # Data node configuration
  data_node_host_type = "FLEX"
  data_node_count             = 1
  data_node_host_ocpu_count   = 4
  data_node_host_memory_gb    = 20
  data_node_storage_gb        = 50

  # Leader node configuration
  master_node_host_type = "FLEX"
  master_node_count             = 1
  master_node_host_ocpu_count   = 1
  master_node_host_memory_gb    = 20

  # OpenSearch Dashboards configuration
  opendashboard_node_count             = 1
  opendashboard_node_host_ocpu_count   = 1
  opendashboard_node_host_memory_gb    = 8

}
