terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "kubernetes_pod_count_per_node_high" {
  source    = "./modules/kubernetes_pod_count_per_node_high"

  providers = {
    shoreline = shoreline
  }
}