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
  env = "dev"
}

provider "google" {
  project = "${var.project}"
}

module "vpc" {
  source  = "../../modules/vpc"
  project = "${var.project}"
  env     = "${local.env}"
}

module "http_server" {
  source      = "../../modules/http_server"
  project     = "${var.project}"
  subnet      = "${module.vpc.subnet}"
  customtags  = ["ssh"]
}

module "firewall" {
  source  = "../../modules/firewall"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
}




#----------------------------

module "besu_node" {
  source  = "../../modules/besu_node"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
  customtags  = ["ssh", "dev"]
  instance_name = "validator99"
#}


#module "gce-worker-container" {
#  source = "./gce-with-container"
  container_image = "gcr.io/google-samples/hello-app:1.0"
  #privileged_mode = true
  #activate_tty = true
  # custom_command = [
  #   "./scripts/start-worker.sh"
  # ]
  # env_variables = {
  #   Q_CLUSTER_WORKERS = "2"
  #   DB_HOST = "your-database-host"
  #   DB_PORT = "5432"
  #   DB_ENGINE = "django.db.backends.postgresql"
  #   DB_NAME = "db_production"
  #   DB_SCHEMA = "jafar_prd"
  #   DB_USER = "role_jafar_prd"
  #   DB_PASS = "this-is-my-honest-password"
  #   DB_USE_SSL = "True"
  # }
  
  #network_name = "default"
  # This has the permission to download images from Container Registry
  #client_email = "custom-gce-dealer@${var.project}.iam.gserviceaccount.com"
}