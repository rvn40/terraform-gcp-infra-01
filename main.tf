# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

provider "google" {
  credentials = file("files/sa/documentorai-400501-3208cc41c332.json")
  project     = "documentorai-400501"
  region      = "asia-southeast1"
}

resource "google_compute_network" "documentorai_vpc_01" {
  name                    = "documentorai-vpc-01"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "documentorai_pubsubnet_01" {
  name          = "documentorai-pubsubnet-01"
  network       = google_compute_network.documentorai_vpc_01.id
  ip_cidr_range = "10.24.0.0/20"
  region        = "asia-southeast1"
}

resource "google_compute_firewall" "documentorai_firewall_internal_becarefullbuddy" {
  name        = "documentorai-firewall-internal-becarefullbuddy"
  description = "Open all connection for internal source"
  network     = google_compute_network.documentorai_vpc_01.id
  source_ranges = [google_compute_subnetwork.documentorai_pubsubnet_01.ip_cidr_range]
  source_tags = ["documentorai-firewall-internal-becarefullbuddy"]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "documentorai_firewall_internal_standardwebport" {
  name        = "documentorai-firewall-internal-standardwebport"
  description = "Open webport connection for internal source"
  network     = google_compute_network.documentorai_vpc_01.id
  source_ranges = [google_compute_subnetwork.documentorai_pubsubnet_01.ip_cidr_range]
  source_tags = ["documentorai-firewall-internal-standardwebport"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "documentorai_firewall_internet_thismotherfckergoesmad" {
  name        = "documentorai-firewall-internet-thismotherfckergoesmad"
  description = "Open all connection for internet source"
  network     = google_compute_network.documentorai_vpc_01.id
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["documentorai-firewall-internet-thismotherfckergoesmad"]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "documentorai_firewall_internet_standardwebport" {
  name        = "documentorai-firewall-internet-standardwebport"
  description = "Open webport connection for internet source"
  network     = google_compute_network.documentorai_vpc_01.id
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["documentorai-firewall-internet-standardwebport"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "documentorai_firewall_internet_dockerapiport" {
  name        = "documentorai-firewall-internet-dockerapiport"
  description = "Open webport connection for internet source"
  network     = google_compute_network.documentorai_vpc_01.id
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["documentorai-firewall-internet-dockerapiport"]
  allow {
    protocol = "tcp"
    ports    = ["2375"]
  }
}

resource "google_compute_firewall" "documentorai_firewall_internet_standardsshport" {
  name        = "documentorai-firewall-internet-standardsshport"
  description = "Open ssh porot connection for internet source"
  network     = google_compute_network.documentorai_vpc_01.id
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["documentorai-firewall-internet-standardsshport"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_instance" "documentorai-vm-01" {
  boot_disk {
    auto_delete = true
    device_name = "documentorai-vm-01"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230918"
      size  = 30
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm-add-tf"
  }

  machine_type = "e2-custom-2-4096"

  metadata = {
    ssh-keys       = "rivan:ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAhiHWyHv+ZJ34vb3yV/ifp7ma8d4lvBViyeVDS4074d48lb+ya3O9oletZXexEyv3pXDtW1gXQIHRZr/Qh0h8TwSTKo+29Obp9QDbP3Nmwp12llDbMiYuXGn7McpuhWUYvW8zTSfPVBNBKtUKf+JiAf3Z4vCYkcAJKx5Xg3Zf2lmwF41E1EJIRAY0qSb87rbDSmyRhdQHhS4aUsLvxGhSYTuf+gh8ohgAPmdAqBU728Waf85l2xUGq4BJMt7EsZWMvOmowtVGJdj4cXH26CtoDgFF5DzL4CPFdztQpNKs5f31SXfhpUNlY7EpZ0jkoNeF5xQf/5EwNt22gbxlHUNwCw== rivan"
    startup-script = "#!/bin/bash\nsudo apt-get update -y\nsudo apt-get install -y zsh\nsudo chsh -s $(which zsh) $(whoami)\ncurl -fsSL https://get.docker.com -o get-docker.sh\nsudo sh get-docker.sh\nsudo usermod -aG docker $(whoami)\nsudo systemctl start docker\nsudo systemctl enable docker\nrm get-docker.sh"
  }

  name = "documentorai-vm-01"

  network_interface {
    access_config {
      network_tier = "STANDARD"
    }

    subnetwork = "projects/documentorai-400501/regions/asia-southeast1/subnetworks/documentorai-pubsubnet-01"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "794906243107-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["documentorai-firewall-internet-standardsshport", "documentorai-firewall-internet-standardwebport"]
  zone = "asia-southeast1-c"
}

resource "google_artifact_registry_repository" "documentorai_be_service" {
  location = "asia-southeast1"
  repository_id = "documentorai-be-service"
  description = "Documentor AI BE service"
  format = "docker"
}

output "documentorai_vpc_01" {
  value = google_compute_network.documentorai_vpc_01.id
}

