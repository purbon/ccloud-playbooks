terraform {
  required_providers {
    confluentcloud = {
      source  = "confluentinc/confluentcloud"
      version = "0.5.0"
    }
  }
}

provider "confluentcloud" {}

data "confluentcloud_environment" "purbon" {
  id = "env-j9wgp"
}

resource "confluentcloud_kafka_cluster" "basic-cluster-on-azure" {
  display_name = "basic_kafka_cluster_on_azure"
  availability = "SINGLE_ZONE"
  cloud        = "AZURE"
  region       = "centralus"
  basic {}

  environment {
    id = data.confluentcloud_environment.purbon.id
  }
}
