# ---------------------------------------------------------------------------------------------------------------------
# THESE TEMPLATES REQUIRE TERRAFORM VERSION 0.10.0 AND ABOVE
# Why? Because we want the latest GCP updates available in https://github.com/terraform-providers/terraform-provider-google
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.10.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE GCE instances to host Solace VMRs on
# ---------------------------------------------------------------------------------------------------------------------

# IP addresses
resource "google_compute_address" "solace-int-ip" {
  count = "${var.num_instances}"

  name         = "${var.name_prefix}-${var.baserouter_name}-ip-${count.index+1}"
  project      = "${var.project_name}"
  region       = "${var.region}"
  subnetwork   = "${var.subnetwork_name}"
  address      = "${var.private_address}"
  address_type = "INTERNAL"
}

# attached disks for docker
resource "google_compute_disk" "solace-disk" {
  count = "${var.num_instances}"

  name    = "${var.name_prefix}-${var.baserouter_name}-disk-${count.index+1}"
  project = "${var.project_name}"
  zone    = "${var.zone}"
  type    = "${var.data_disk_type}"
  size    = "${var.data_disk_size}"
}

resource "google_compute_instance" "solace-instance" {
  count = "${var.num_instances}"

  name         = "${var.name_prefix}-${var.baserouter_name}-${count.index+1}"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  project      = "${var.project_name}"

  tags                    = ["${concat(list(var.project_name), list(var.instance_tag_name), var.custom_tags)}"]
  metadata                = "${var.custom_metadata}"
  metadata_startup_script = "${data.template_file.startup_script_solace_sec.rendered}"

  boot_disk {
    initialize_params {
      size  = "${var.boot_disk_size}"
      type  = "${var.boot_disk_type}"
      image = "${var.image_project}/${var.image_family}"
    }
  }

  attached_disk {
    source = "${google_compute_disk.solace-disk.*.self_link[count.index]}"
  }

  // Local SSD disk
  // scratch_disk {}

  network_interface {
    subnetwork = "${var.subnetwork_name}"
    network_ip = "${google_compute_address.solace-int-ip.*.address[count.index]}"

    access_config {
      nat_ip = ""
    }
  }
  service_account {
    scopes = "${var.service_account_scopes}"
  }
  allow_stopping_for_update = "${var.allow_stopping_for_update}"
}

# Render the startup script that needs to be run on each VMR server
data "template_file" "startup_script_solace_sec" {
  template = "${file("${path.module}/examples/install-broker/solos-install.sh")}"

  vars {
    project                  = "${var.project_name}"
    region                   = "${var.region}"
    region_zone              = "${var.zone}"
    router_password          = "${var.password}"
    type                     = "${var.image_type}"
    router_role              = "singleton"
    type                     = "${var.image_type}"
    redundancy               = "${var.redundancy}"
    redundacy_group_password = "${var.redundancy_group_password}"
    scaling                  = "${var.max_connections}"
    baseroutername           = "${var.baserouter_name}"
    monitor_ip               = ""
    primary_ip               = ""
    secondary_ip             = ""
  }
}
