terraform {
  required_providers {
    confluentcloud = {
      source  = "confluentinc/confluentcloud"
      version = "0.5.0"
    }
  }
}

provider "confluentcloud" {}

variable "api_key" {}
variable "api_secret" {}

data "confluentcloud_environment" "purbon" {
  id = "env-j9wgp"
}

data "confluentcloud_kafka_cluster" "basic-cluster" {
  id = "lkc-223xxq"
  environment {
    id = data.confluentcloud_environment.purbon.id
  }
}


resource "confluentcloud_service_account" "my_sa" {
  display_name = "my_sa"
  description = "description for the sa"
}


resource "confluentcloud_kafka_topic" "orders" {
  kafka_cluster = data.confluentcloud_kafka_cluster.basic-cluster.id
  topic_name = "orders"
  partitions_count = 40
  http_endpoint = data.confluentcloud_kafka_cluster.basic-cluster.http_endpoint
  config = {
    "cleanup.policy" = "compact"
    "max.message.bytes" = "12345"
    "retention.ms" = "67890"
  }
  credentials {
    key = var.api_key
    secret = var.api_secret
  }
}

resource "confluentcloud_kafka_topic" "mas_orders" {
  kafka_cluster = data.confluentcloud_kafka_cluster.basic-cluster.id
  topic_name = "menos.orders"
  partitions_count = 4
  http_endpoint = data.confluentcloud_kafka_cluster.basic-cluster.http_endpoint
  config = {
    "cleanup.policy" = "compact"
    "max.message.bytes" = "12345"
    "retention.ms" = "67890"
  }
  credentials {
    key = var.api_key
    secret = var.api_secret
  }
}

resource "confluentcloud_kafka_acl" "describe-basic-cluster" {
  kafka_cluster = data.confluentcloud_kafka_cluster.basic-cluster.id
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type = "LITERAL"
  principal =  "User:${confluentcloud_service_account.my_sa.id}"
  operation = "DESCRIBE"
  permission = "ALLOW"
  http_endpoint = data.confluentcloud_kafka_cluster.basic-cluster.http_endpoint
  credentials {
    key = var.api_key
    secret = var.api_secret
  }
}

resource "confluentcloud_role_binding" "cluster-admin-rb" {
  principal = "User:${confluentcloud_service_account.my_sa.id}"
  role_name  = "CloudClusterAdmin"
  crn_pattern = data.confluentcloud_kafka_cluster.basic-cluster.rbac_crn
}
