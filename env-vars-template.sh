# Authentication details
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..****************************"
export TF_VAR_user_ocid="ocid1.user.oc1..**********************************"
export TF_VAR_fingerprint="38:4b:39:f0:03:39:1f:******************"
export TF_VAR_private_key_path="C:\Travail\*****\Demos\*****\NewAPIKeys\************.pem"

# Compartment
export TF_VAR_compartment_ocid="ocid1.compartment.oc1..*****************************"

# Region
export TF_VAR_region="eu-frankfurt-1"

# Network
export TF_VAR_private_subnet_ocid="ocid1.subnet.oc1.eu-frankfurt-1.*************************"
export TF_VAR_public_subnet_ocid="ocid1.subnet.oc1.eu-frankfurt-1.**************************"


# Availability Domain
export TF_VAR_availability_domain="Vihs:EU-FRANKFURT-1-AD-1"

# IMAGE URL and Registry Secret
export TF_VAR_ci_image_url="fra.ocir.io/*********/*********:0.0.4-SNAPSHOT"
export TF_VAR_ci_image_url_bis="fra.ocir.io/*********/*********:0.0.4-SNAPSHOT"
export TF_VAR_ci_registry_secret="ocid1.vaultsecret.oc1.eu-frankfurt-1.****************"

# NUMBER of CI
export TF_VAR_ci_count=1
export TF_VAR_ci_count_bis=1

# Container ENV variables
export TF_VAR_ci_container_env_variables='{ DATABASE_URL = "mysql://username:xyz@ip:port/db-name", DEVELOPMENT_MODE = "on" }'


# API-Gateway
export TF_VAR_public_apigateway_ocid="ocid1.apigateway.oc1.eu-frankfurt-1.**************************"
