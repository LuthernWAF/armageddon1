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

resource google_compute_network eu_network {
    name = "armageddon1-task3-vpc1-${random_string.rstring.result}"
    auto_create_subnetworks = false
}

resource google_compute_network am1_network {
    name = "armageddon1-task3-vpc2-${random_string.rstring.result}"
    auto_create_subnetworks = false
}

resource google_compute_network am2_network {
    name = "armageddon1-task3-vpc3-${random_string.rstring.result}"
    auto_create_subnetworks = false
}

/*
resource google_compute_network apac_network {
    name = "armageddon1-task3-vpc4-${random_string.rstring.result}"
    auto_create_subnetworks = false
}
*/

resource google_compute_subnetwork eu_subnetwork {
    name = "armageddon1-task3-vpc1-subnet-${random_string.rstring.result}"
    ip_cidr_range = "10.0.1.0/24"
    network = google_compute_network.eu_network.id
    region = "europe-west1"
}

resource google_compute_subnetwork am1_subnetwork {
    name = "armageddon1-task3-vpc2-subnet-${random_string.rstring.result}"
    ip_cidr_range = "172.16.1.0/24"
    network = google_compute_network.am1_network.id
    region = "us-west1"
}

resource google_compute_subnetwork am2_subnetwork {
    name = "armageddon1-task3-vpc3-subnet-${random_string.rstring.result}"
    ip_cidr_range = "172.16.2.0/24"
    network = google_compute_network.am2_network.id
    region = "us-east1"
}

/*
resource google_compute_subnetwork apac_subnetwork {
    name = "armageddon1-task3-vpc4-subnet-${random_string.rstring.result}"
    ip_cidr_range = "192.168.1.0/24"
    network = google_compute_network.apac_network.id
    region = "asia-east1"
}
*/

resource google_compute_firewall eu_firewall_ping_ingress {
    name = "armageddon1-task3-firewall1-${random_string.rstring.result}"
    network = google_compute_network.eu_network.id

    allow {
        protocol = "icmp"
    }

    source_ranges = ["0.0.0.0/0"]
}

resource google_compute_firewall eu_firewall_http_ingress {
    name = "armageddon1-task3-firewall2-${random_string.rstring.result}"
    network = google_compute_network.eu_network.id

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    source_ranges = ["172.16.1.0/24", "172.16.2.0/24"]
}

resource google_compute_firewall am1_firewall_http_ingress {
    name = "armageddon1-task3-firewall3-${random_string.rstring.result}"
    network = google_compute_network.am1_network.id

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    source_ranges = ["10.0.1.0/24"]
}

resource google_compute_firewall am1_firewall_ssh_ingress {
    name = "armageddon1-task3-firewall4-${random_string.rstring.result}"
    network = google_compute_network.am1_network.id

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource google_compute_firewall am2_firewall_http_ingress {
    name = "armageddon1-task3-firewall5-${random_string.rstring.result}"
    network = google_compute_network.am2_network.id

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    source_ranges = ["10.0.1.0/24"]
}

resource google_compute_firewall am2_firewall_ssh_ingress {
    name = "armageddon1-task3-firewall6-${random_string.rstring.result}"
    network = google_compute_network.am2_network.id

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource google_compute_network_peering eu_am1_network_peering {
    name = "armageddon1-task3-peering1-${random_string.rstring.result}"
    peer_network = google_compute_network.am1_network.id
    network = google_compute_network.eu_network.id
}

resource google_compute_network_peering eu_am2_network_peering {
    name = "armageddon1-task3-peering2-${random_string.rstring.result}"
    peer_network = google_compute_network.am2_network.id
    network = google_compute_network.eu_network.id
}

resource google_compute_network_peering am1_eu_network_peering {
    name = "armageddon1-task3-peering3-${random_string.rstring.result}"
    network = google_compute_network.am1_network.id
    peer_network = google_compute_network.eu_network.id
}

resource google_compute_network_peering am2_eu_network_peering {
    name = "armageddon1-task3-peering4-${random_string.rstring.result}"
    network = google_compute_network.am2_network.id
    peer_network = google_compute_network.eu_network.id
}

resource google_compute_instance eu_vm {
    name = "armageddon1-task3-instance1-${random_string.rstring.result}"
    machine_type = "n2-standard-2"
    zone = "europe-west1-b"
    network_interface {
        network = google_compute_network.eu_network.id
        subnetwork = google_compute_subnetwork.eu_subnetwork.id
    }

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    metadata_startup_script = "apt update\napt install -y apache2 "
    tags = ["http-server"]
}

resource google_compute_instance am1_vm {
    name = "armageddon1-task3-instance2-${random_string.rstring.result}"
    machine_type = "n2-standard-2"
    zone = "us-west1-a"
    network_interface {
        network = google_compute_network.am1_network.id
        subnetwork = google_compute_subnetwork.am1_subnetwork.id

        access_config {
            network_tier = "STANDARD"
        }
    }

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }
}

resource google_compute_instance am2_vm {
    name = "armageddon1-task3-instance3-${random_string.rstring.result}"
    machine_type = "n2-standard-2"
    zone = "us-east1-b"
    network_interface {
        network = google_compute_network.am2_network.id
        subnetwork = google_compute_subnetwork.am2_subnetwork.id

        access_config {
            network_tier = "STANDARD"
        }
    }

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }
}
