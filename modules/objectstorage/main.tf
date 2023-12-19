variable "root_compartment_ocid" {
  // Description or default value (if any) for compartment_ocid
}

variable "compartment_ocid" {
  // Description or default value (if any) for compartment_ocid
}


variable "compartment_name" {
  // Description or default value (if any) for compartment_name
} 

variable "objectstorage_namespace" {
  // Description or default value (if any) for objectstorage_namespace
}

variable "objectstorage_bucket_name" {
  // Description or default value (if any) for objectstorage_bucket_name
}

variable "objectstorage_group_name"{
    description = "objectstorage_group_name"
    type        = string
    default     = "invocing-app-objectstorage"
    
}

// https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket
resource "oci_objectstorage_bucket" "bucket" {
    namespace = var.objectstorage_namespace
    name      = var.objectstorage_bucket_name
    compartment_id = var.compartment_ocid

    # optional
    auto_tiering = "InfrequentAccess"
    access_type = "NoPublicAccess"
}


resource "oci_identity_group" "group" {
   name = "${var.objectstorage_group_name}"
   description = "access to invoicing-app object storage"
   compartment_id = var.root_compartment_ocid
}


resource "oci_identity_policy" "bucket_policy" {
  name = "object_storage_policy"
  description = "object_storage_policy"
  compartment_id = var.compartment_ocid
  statements = [
    # "Allow group invocing-apis to read buckets in compartment ${var.compartment_name}",
    "Allow group ${var.objectstorage_group_name} to manage objects in compartment ${var.compartment_name}"
  ]
}

