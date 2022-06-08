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

resource "confluentcloud_kafka_cluster" "dedicated-cluster-pl" {
  display_name = "dedicated_kafka_cluster_for_pl"
  availability = "MULTI_ZONE"
  cloud        = "AWS"
  region       = "eu-west-1"
  dedicated {
    cku = 3
  }

  environment {
    id = data.confluentcloud_environment.purbon.id
  }
}
