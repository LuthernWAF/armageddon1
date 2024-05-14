/*
terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "3.85.0"
        }
    }
}
*/

resource random_string rstring {
    length = 6
    special = false
    upper = false
}

provider "google" {
    project = "armageddon1"
    region = "us-west1"
    zone = "us-west1-a"
}

resource google_compute_network vpc_network {
    name = "armageddon1-task2-vpc-${random_string.rstring.result}"
    auto_create_subnetworks = false
}

resource google_compute_subnetwork vpc_subnetwork {
    name = "armageddon1-task2-vpc-subnet-${random_string.rstring.result}"
    ip_cidr_range = "10.177.1.0/24"
    network = google_compute_network.vpc_network.id
}

resource google_compute_firewall vpc_firewall {
    name = "armageddon1-task2-vpc-firewall-${random_string.rstring.result}"
    network = google_compute_network.vpc_network.id
    allow {
        protocol = "tcp"
        ports = ["80"]
    }
    source_ranges = ["0.0.0.0/0"]
}

resource google_compute_instance vpc_vm {
    name = "armageddon1-task2-vpc-instance-${random_string.rstring.result}"
    machine_type = "n2-standard-2"
    network_interface {
        network = google_compute_network.vpc_network.id
        subnetwork = google_compute_subnetwork.vpc_subnetwork.id

        access_config {
            network_tier = "STANDARD"
        }
    }

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    metadata_startup_script = "apt update\napt install -y apache2 "
}

resource local_file vpc_vm_file {
    filename = "armageddon_task2_info.txt"
    content = "${google_compute_instance.vpc_vm.network_interface[0].access_config[0].nat_ip}\n${google_compute_network.vpc_network.id}\n${google_compute_subnetwork.vpc_subnetwork.id}\n${google_compute_instance.vpc_vm.network_interface[0].network_ip}"
}