# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

#--boot-disk-size=60GB --boot-disk-type=pd-ssd --boot-disk-device-name=instance-1
variable "name_prefix" {
  description = "prefix all the Vms with a nice name, project?"
}

variable "region" {
  description = "All GCP resources will be launched in this Region."
}

variable "zone" {
  description = "All GCP resources will be launched in this Zone."
}

variable "machine_type" {
  description = "The machine type of the Compute Instance to run for each node in the cluster (e.g. n1-standard-1)."
}

variable "instance_tag_name" {
  description = "tags assigned to these instances so we can use them for rules"
}

variable "project_name" {
  description = "project name"
}

variable "baserouter_name" {
  description = "basename for the Solace router, cannot contain dashes or underscores. baserouter_name + 0 for monitoring node, +1 for primary and +2 for secondary"
}

variable "password" {
  description = "password for the Solace router"
}

variable "redundancy_group_password" {
  description = "password for the redundancy group"
}


# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "num_instances" {
  description = "Number of instances"
  default     = "1"
}

variable "image_type" {
  description = "image type to download: standard or enterprise"
  default     = "enterprise"
}

variable "role" {
  description = "role for the Solace router, options: monitor, primary, backup, singleton (no redundancy)"
  default     = "singleton"
}


variable "redundancy" {
  description = "if the Solace routers should be configured as a HA pair or not (no|yes)"
  default     = "no"
}

variable "source_ranges" {
  description = "Allow access from appliance for following source ranges"
  type = "list"
  default = [ ]
}

variable "max_connections" {
  description = "Number of connections the appliance accpets"
  default = "100"
}

  variable "allow_onprem_cidr" {
  description = "Allow access from a an on-prem range, say a VPN tunnel"
  type = "list"
  default = [ "192.168.32.0/19", "10.10.135.0/24", "10.10.136.0/24"]
}

variable "image_project" {
  description = "Project the image belongs to"
  default     = "centos-cloud"
}

variable "image_family" {
  description = "Familfy image belongs to"
  default     = "centos-7"
}

variable  "boot_disk_size" {
  description = "The size of the boot disk"
  default     = "30"
}

variable "boot_disk_type" {
  description = "Type of the boot disk"
  default     = "pd-ssd"
}

variable  "data_disk_size" {
  description = "The size of the boot disk"
  default     = "100"
}

variable "data_disk_type" {
  description = "Type of the boot disk"
  default     = "pd-ssd"
}

variable "network_name" {
  description = "The name of the VPC Network where all resources should be created."
  default = "default"
}

variable "private_address" {
  description = "The private IP address to assign to the instance, if empty, the address will be automatically assigned."
  default     = ""
}

variable "subnetwork_name" {
  description = "The name of the subnet"
  default     = "default"
}

variable "custom_tags" {
  description = "A list of tags that will be added to the Compute Instance Template in addition to the tags automatically added by this module."
  type = "list"
  default = ["vmr", "solace", "pubsub"]
}

variable "custom_metadata" {
  description = "A map of metadata key value pairs to assign to the Compute Instance metadata."
  type = "map"
  default = { "function" = "pubsub", "vendor" = "solace"}
}

variable "firewall_direction" {
  description = "Direction of traffic to which this firewall applies; One of INGRESS or EGRESS. Defaults to INGRESS."
  default     = "INGRESS"
}

variable "allow_stopping_for_update" {
  description = "Allow the VM to be stopped to update it"
  default     = false
}

variable "service_account_scopes" {
  description = "scopes for service account"
  type        = "list"
  default     = ["userinfo-email", "compute-ro", "storage-full"]
}

# Firewall Ports

variable "solace_http_port" {
  description = "Web Transport - WebSockets, Comet, etc."
  default = 80
}

variable "solace_semp_port" {
  description = "SEMP - SolAdmin"
  default = 8080
}

variable "solace_mqtt_default_port" {
  description = "MQTT access 'default' VPN"
  default = 1883
}

variable "solace_mqtt_websockets_port" {
  description = "MQTT / WebSockets 'default' VPN"
  default = 8000
}

variable "solace_rest_port" {
  description = "REST 'default' VPN"
  default = 9000
}

variable "solace_smf" {
  description = "Solace Message Format (SMF)"
  default = 55003
}

variable "solace_smf_compressed" {
  description = "SMF compressed"
  default = 55555
}

variable "solace_smf_ctrl" {
  description = "SMF control port MNR"
  default = 55556
}
