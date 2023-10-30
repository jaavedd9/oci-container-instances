# Terraform Automation on Oracle Cloud : Migrate from V1 to V2 with x Container Instances (private network) without service interruption (due to the use of a Loab Balancer (public network) to access them)

This project has been designed to run inside Oracle OCI Stacks Resource Manager (so simply with terraform). Nevertheless you can use it outside OCI Stacks Resource Manager but you should uncomment some lines in 3 files (variables.tf, provider.tf and main.tf). In these 3 files I put information on where you need to uncomment.

Note 1 : You must know Terraform to use id (Terraform Plan, Apply, Delete, ..)

Note 2 : A new module for the OCI dns is added so the OCI Domain Name will be created automatically.

## Prerequisites

Before Starting you need to create a Secret in Oracle OCI Vault for being able to connect to the OCI Registry where your docker images for Container Instances are stored.

1) Create the secret. It is a JSON String like below : 
 - optional when policy gives the dyanamic group of CI access to fetch
{
"username": "charles-foster-kane",
"password": "rosebud"
} 

2) Create a Dynamic Group for Container Instance in your compratment
   
"Any {resource.type = 'computecontainerinstance', resource.compartment.id = 'ocid1.compartment.oc1..aaaaaaaax6vcsmyeticnpfvvixqk5lyqgihqbjvhcxfakuruoyv4dr4utq7q'}"

3) Create a Policy to allow Container Instance read Secret

allow dynamic-group <dynamic-group-name> to read secret-bundles in tenancy
allow dynamic-group <dynamic-group-name> to read repos in tenancy	

## Create the Stack

This project consider that your network configuration is done. It means : 
- VCN is created with a private subnet and a public subnet
- The security list of the public subnet has an ingress rule for the load balancer port
- The security list of the private subnet has an ingress rule for the container instances port

You can look at the variables and see : 
- Some of the variables have default values than can be updated by yourself or not (using the env-var-template.ps1(or.sh) or with Stack Ressource Manager Variables)
- Some other variables have no default value and are mandatory so you must know them.
  - compartment_ocid
  - region
  - private_subnet_ocid
  - public_subnet_ocid
  - ci_image_url (Image version V1)
  - ci_image_url_bis (Image version V2)
  - ci_registry_secret (ocid) # optional when policy gives the dyanamic group of CI access to fetch the repos 
  - domain name of the OCI DNS (that makes the relation with the LB IP Address)

## Migrate from V1 to V2 without interruption service

Very simple just follow this sequence :  

1) At start ci_image_url = ci_image_url_bis = Image_Docker_V1. Do a terraform apply and create the architecture. Use the Load Balancer Ip address to check that all is ok.
2) First in terraform  change ci_image_url_bis = Image_Docker_V2. Do a terraform apply and upgrade one container instance bis. The container instance bis will be deleted then created with new version. At the end you have 50% V1 and 50% V2. You can consider it is a kind of "canary release". Note that in the terraform script you have 2 other parameters ci_count and ci_count_bis for the number of Container instances so you can do what you want during the miggration sequence. Ex : having 2 CI in V1 and 1 in V2. Note that it takes about 1min15s to create the new CI + 15s to register the CI behind the Load balancer + a few second for the LOB to chack that the new Backend is there.
3) Then in terraform change ci_image_url = Image_Docker_V2. Do a terraform apply and upgrade one container instance. At the end the new version V2 is deployed everywhere.

Note : I did a load test using Apache JMeter during the test and I got 0% error with a fast rest service (30ms) and a slow rest service (500 ms). Nevertheless you must do tests yourself to check that all is ok. 

## Some ideas
- If problem you can come back to V1 easily.
- You can do canary release as you want. Ok May be you will have more CI instead of 2 (just to get the % of V2 that you want) but only for 1h for ex (time to check that everything is Ok).
- Natively you have a HA architecture (cause several CI and LB is HA)
- You can improve the terraform script using 2 variables application_version and application_version_bis and use these variable for the name of the CI so you will know immediately the version deployed just looking at the name of the CI.
- You can have Disaster Recovery. You can buy a domain name somewhere (ex : godaddy) and use the Oracle OCI DNS in order to not use directly the Ip Adress of the LB in region 1. In this case you will be able to switch from region 1 to region 2 in about 10 minutes. You use terraform to create the architecture on the region 2 (5 min) and you update the ip Address of the LB in the Oracle OCI DNS (5 min to see the update calling the url. This last time is not a guaranty, it depends on several parameters but in general it is possible in 5 minutes).
