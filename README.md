# google-solace-pubsub+ module

Deploys a GCP compute instance and sets up a solace pubsub+ docker instance



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allow\_onprem\_cidr | Allow access from a an on-prem range, say a VPN tunnel | list | `<list>` | no |
| allow\_stopping\_for\_update | Allow the VM to be stopped to update it | string | `"false"` | no |
| baserouter\_name | basename for the Solace router, cannot contain dashes or underscores. baserouter_name + 0 for monitoring node, +1 for primary and +2 for secondary | string | n/a | yes |
| boot\_disk\_size | The size of the boot disk | string | `"30"` | no |
| boot\_disk\_type | Type of the boot disk | string | `"pd-ssd"` | no |
| custom\_metadata | A map of metadata key value pairs to assign to the Compute Instance metadata. | map | `<map>` | no |
| custom\_tags | A list of tags that will be added to the Compute Instance Template in addition to the tags automatically added by this module. | list | `<list>` | no |
| data\_disk\_size | The size of the boot disk | string | `"100"` | no |
| data\_disk\_type | Type of the boot disk | string | `"pd-ssd"` | no |
| firewall\_direction | Direction of traffic to which this firewall applies; One of INGRESS or EGRESS. Defaults to INGRESS. | string | `"INGRESS"` | no |
| image\_family | Familfy image belongs to | string | `"centos-7"` | no |
| image\_project | Project the image belongs to | string | `"centos-cloud"` | no |
| image\_type | image type to download: standard or enterprise | string | `"enterprise"` | no |
| instance\_tag\_name | tags assigned to these instances so we can use them for rules | string | n/a | yes |
| machine\_type | The machine type of the Compute Instance to run for each node in the cluster (e.g. n1-standard-1). | string | n/a | yes |
| max\_connections | Number of connections the appliance accpets | string | `"100"` | no |
| name\_prefix | prefix all the Vms with a nice name, project? | string | n/a | yes |
| network\_name | The name of the VPC Network where all resources should be created. | string | `"default"` | no |
| num\_instances | Number of instances | string | `"1"` | no |
| password | password for the Solace router | string | n/a | yes |
| private\_address | The private IP address to assign to the instance, if empty, the address will be automatically assigned. | string | `""` | no |
| project\_name | project name | string | n/a | yes |
| redundancy | if the Solace routers should be configured as a HA pair or not (no|yes) | string | `"no"` | no |
| redundancy\_group\_password | password for the redundancy group | string | n/a | yes |
| region | All GCP resources will be launched in this Region. | string | n/a | yes |
| role | role for the Solace router, options: monitor, primary, backup, singleton (no redundancy) | string | `"singleton"` | no |
| service\_account\_scopes | scopes for service account | list | `<list>` | no |
| solace\_http\_port | Web Transport - WebSockets, Comet, etc. | string | `"80"` | no |
| solace\_mqtt\_default\_port | MQTT access 'default' VPN | string | `"1883"` | no |
| solace\_mqtt\_websockets\_port | MQTT / WebSockets 'default' VPN | string | `"8000"` | no |
| solace\_rest\_port | REST 'default' VPN | string | `"9000"` | no |
| solace\_semp\_port | SEMP - SolAdmin | string | `"8080"` | no |
| solace\_smf | Solace Message Format (SMF) | string | `"55003"` | no |
| solace\_smf\_compressed | SMF compressed | string | `"55555"` | no |
| solace\_smf\_ctrl | SMF control port MNR | string | `"55556"` | no |
| source\_ranges | Allow access from appliance for following source ranges | list | `<list>` | no |
| subnetwork\_name | The name of the subnet | string | `"default"` | no |
| zone | All GCP resources will be launched in this Zone. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| solace\_instance\_id | TF outputs |
| solace\_private\_ip\_addresses |  |
| solace\_public\_ip\_addresses |  |

