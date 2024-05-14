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

resource google_storage_bucket website_bucket {
    name = "armageddon1_task1_bucket_${random_string.rstring.result}"
    location = "US"
    website {
        main_page_suffix = "index.html"
    }
}

resource google_storage_bucket_object website_bucket_content {
    name = "index.html"
    content = "Terraform Task1 Text"
    bucket = google_storage_bucket.website_bucket.name
}

resource google_storage_object_access_control website_bucket_acl {
    object = google_storage_bucket_object.website_bucket_content.name
    bucket = google_storage_bucket.website_bucket.name
    role = "READER"
    entity = "allUsers"
}

resource local_file website_bucket_url {
    filename = "armageddon_task1_url.txt"
    content = "https://storage.googleapis.com/${google_storage_bucket.website_bucket.name}/${google_storage_bucket_object.website_bucket_content.name}"
}