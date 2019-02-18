## Usage

This branch is for non-ha solace setup, which allows for multple solace routers to be setup

### call the module
```
module "google-vmr-instances" {
  source                  = "<git url>/google-compute-instance.git"
  num_instances           = "1"
  name_prefix             = "${var.project_name}-solace-vmr"
  gcp_zone                = "${var.region_zone}"
  machine_type            = "n1-standard-2"
  boot_disk_size          = "120"
  instance_tag_name       = "solace-vmr"
  project_name            = "${google_project.service_project.project_id}"
  subnetwork_name         = "${data.terraform_remote_state.global.shared_sg_subnet}"
  private_address         = "${google_compute_address.vmr1.address}"
  service_account_scopes  = ["userinfo-email", "compute-ro", "storage-ro"]
  startup_script          = "${data.template_file.startup_script_solace.rendered}"
}
```
### Render the startup script that needs to be run on each VMR server
```
data "template_file" "startup_script_solace" {
  template = "${file("../../modules/google-solace-vmr/examples/install-vmr/startup-script-server.sh")}"

  vars {
    docker_image        = "${format("%s/%s", google_storage_bucket.scripts-store.url, var.solace_docker_image)}"
    vmr_install-script  = "${format("%s/vmr-install.sh", google_storage_bucket.scripts-store.url)}"
    vmr_password        = "${var.vmr_password}"
    max_connections     = "1000"
  }
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allow_onprem_cidr | Allow access from a an on-prem range, say a VPN tunnel | list | `<list>` | no |
| allow_stopping_for_update | Allow the VM to be stopped to update it | string | `false` | no |
| assign_public_ip_addresses | If true, each of the Compute Instances will receive a public IP address and be reachable from the Public Internet (if Firewall rules permit). If false, the Compute Instances will have private IP addresses only. In production, this should be set to false. | string | `true` | no |
| boot_disk_size | The size of the boot disk | string | `30` | no |
| boot_disk_type | Type of the boot disk | string | `pd-ssd` | no |
| custom_metadata | A map of metadata key value pairs to assign to the Compute Instance metadata. | map | `<map>` | no |
| custom_tags | A list of tags that will be added to the Compute Instance Template in addition to the tags automatically added by this module. | list | `<list>` | no |
| firewall_direction | Direction of traffic to which this firewall applies; One of INGRESS or EGRESS. Defaults to INGRESS. | string | `INGRESS` | no |
| gcp_zone | All GCP resources will be launched in this Zone. | string | - | yes |
| image_family | Familfy image belongs to | string | `centos-7` | no |
| image_project | Project the image belongs to | string | `centos-cloud` | no |
| machine_type | The machine type of the Compute Instance to run for each node in the cluster (e.g. n1-standard-1). | string | - | yes |
| name_prefix | prefix all the Vms with a nice name, project? | string | - | yes |
| network_name | The name of the VPC Network where all resources should be created. | string | `default` | no |
| num_instances | Number of instances | string | `1` | no |
| project_name | project name | string | - | yes |
| solace_http_port | Web Transport - WebSockets, Comet, etc. | string | `80` | no |
| solace_mqtt_default_port | MQTT access 'default' VPN | string | `1883` | no |
| solace_mqtt_websockets_port | MQTT / WebSockets 'default' VPN | string | `8000` | no |
| solace_rest_port | REST 'default' VPN | string | `9000` | no |
| solace_semp_port | SEMP - SolAdmin | string | `8080` | no |
| solace_smf | Solace Message Format (SMF) | string | `55003` | no |
| solace_smf_compressed | SMF compressed | string | `55555` | no |
| solace_smf_ctrl | SMF control port MNR | string | `55556` | no |
| startup_script | Solace VMR startup script | string | `#!/bin/bash if [ ! -f /var/lib/solace ]; then   mkdir /var/lib/solace   cd /var/lib/solace   yum install -y wget   wget https://raw.githubusercontent.com/SolaceLabs/solace-gcp-quickstart/master/vmr-install.sh   chmod +x /var/lib/solace/vmr-install.sh   /var/lib/solace/vmr-install.sh -i http://em.solace.com/hdm1c4B00C000hikY000Ibz -p asheeBohx4ie fi ` | no |
| subnetwork_name | The name of the subnet | string | `default` | no |
| vmr_tag_name | tags assigned to these instances so we can use them for rules | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| debug_length |  |

