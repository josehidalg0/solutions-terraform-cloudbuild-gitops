# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


locals {
  network = "${element(split("-", var.subnet), 0)}"
}


module "gce-container" {
  source = "terraform-google-modules/container-vm/google"
  version = "~> 3.0.0"

  cos_image_name = "cos-stable-97-16919-29-58"

  container = {
    image=  "gcr.io/google-containers/alpine-with-bash" ##var.container_image #
    #env = local.env_variables
    # env = [
    #   {
    #     name = "TEST_VAR"
    #     value = "Hello World!"
    #   }
    # ],

    # Declare volumes to be mounted.
    # This is similar to how docker volumes are declared.
    # volumeMounts = [
    #   {
    #     mountPath = "/cache"
    #     name      = "tempfs-0"
    #     readOnly  = false
    #   },
    #   {
    #     mountPath = "/persistent-data"
    #     name      = "data-disk-0"
    #     readOnly  = false
    #   },
    # ]
    }

  # Declare the Volumes which will be used for mounting.
  volumes = [
    {
      name = "tempfs-0"

      emptyDir = {
        medium = "Memory"
      }
    },
    {
      name = "data-disk-0"

      gcePersistentDisk = {
        pdName = "data-disk-0"
        fsType = "ext4"
      }
    },
  ]

  restart_policy = "Always"
}

####################
##### COMPUTE ENGINE
resource "google_compute_instance" "default" {
  name = var.instance_name
  project      = "${var.project}"
  zone         = "europe-west1-b"
  machine_type = "e2-small" #"f1-micro"
  
  # If true, allows Terraform to stop the instance to update its properties.
  scheduling {
    automatic_restart = true
  }

  allow_stopping_for_update = true

  lifecycle {
    ignore_changes = [attached_disk]
  }

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }
  network_interface {
    subnetwork = "${var.subnet}"

#    network = var.network_name
    access_config {}
  }

  # metadata = {
  #   gce-container-declaration = module.gce-container.metadata_value
  # }

  # labels = {
  #   container-vm = module.gce-container.vm_container_label
  # }
  tags = concat(["besu-node"], var.customtags)

  # service_account {
  #   email = var.client_email
  #   scopes = [
  #     "https://www.googleapis.com/auth/cloud-platform",
  #   ]
  # }
}