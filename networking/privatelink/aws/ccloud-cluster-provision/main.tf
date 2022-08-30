terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 2.32.0"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.2.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

data "confluent_environment" "purbon" {
  id = var.confluent_cloud_environment
}

resource "confluent_network" "private-link" {
  display_name     = "Private Link Network"
  cloud            = "AWS"
  region           = var.region
  connection_types = ["PRIVATELINK"]
  zones            = keys(var.subnets_to_privatelink)
  environment {
    id = data.confluent_environment.purbon.id
  }
}

resource "confluent_private_link_access" "aws" {
  display_name = "AWS Private Link Access"
  aws {
    account = var.aws_account_id
  }
  environment {
    id = data.confluent_environment.purbon.id
  }
  network {
    id = confluent_network.private-link.id
  }
}

resource "confluent_kafka_cluster" "dedicated-cluster-pl" {
  display_name = "dedicated_kafka_cluster_for_pl"
  availability = "MULTI_ZONE"
  cloud        = confluent_network.private-link.cloud
  region       = confluent_network.private-link.region
  dedicated {
    cku = 3
  }

  environment {
     id = data.confluent_environment.purbon.id
  }
  network {
     id = confluent_network.private-link.id
  }
}



// 'app-manager' service account is required in this configuration to create 'orders' topic and assign roles
// to 'app-producer' and 'app-consumer' service accounts.
# resource "confluent_service_account" "app-manager" {
#   display_name = "app-manager"
#   description  = "Service account to manage 'inventory' Kafka cluster"
# }
#
# resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
#   principal   = "User:${confluent_service_account.app-manager.id}"
#   role_name   = "CloudClusterAdmin"
#   crn_pattern = confluent_kafka_cluster.dedicated-cluster-pl.rbac_crn
# }
#
# resource "confluent_api_key" "app-manager-kafka-api-key" {
#   display_name = "app-manager-kafka-api-key"
#   description  = "Kafka API Key that is owned by 'app-manager' service account"
#   owner {
#     id          = confluent_service_account.app-manager.id
#     api_version = confluent_service_account.app-manager.api_version
#     kind        = confluent_service_account.app-manager.kind
#   }
#
#   managed_resource {
#     id          = confluent_kafka_cluster.dedicated-cluster-pl.id
#     api_version = confluent_kafka_cluster.dedicated-cluster-pl.api_version
#     kind        = confluent_kafka_cluster.dedicated-cluster-pl.kind
#
#     environment {
#       id = data.confluent_environment.purbon.id
#     }
#   }
#
#   # The goal is to ensure that
#   # 1. confluent_role_binding.app-manager-kafka-cluster-admin is created before
#   # confluent_api_key.app-manager-kafka-api-key is used to create instances of
#   # confluent_kafka_topic resource.
#   # 2. Kafka connectivity through AWS PrivateLink is setup.
#   depends_on = [
#     confluent_role_binding.app-manager-kafka-cluster-admin,
#
#     confluent_private_link_access.aws,
#     aws_vpc_endpoint.privatelink,
#     aws_route53_record.privatelink,
#     aws_route53_record.privatelink-zonal,
#   ]
# }
#
# resource "confluent_kafka_topic" "orders" {
#   kafka_cluster {
#     id = confluent_kafka_cluster.dedicated-cluster-pl.id
#   }
#   topic_name    = "orders"
#   http_endpoint = confluent_kafka_cluster.dedicated-cluster-pl.http_endpoint
#   credentials {
#     key    = confluent_api_key.app-manager-kafka-api-key.id
#     secret = confluent_api_key.app-manager-kafka-api-key.secret
#   }
# }


# https://docs.confluent.io/cloud/current/networking/private-links/aws-privatelink.html
# Set up the VPC Endpoint for AWS PrivateLink in your AWS account
# Set up DNS records to use AWS VPC endpoints
 provider "aws" {
   region = var.region
 }

locals {
  hosted_zone = replace(regex("^[^.]+-([0-9a-zA-Z]+[.].*):[0-9]+$", confluent_kafka_cluster.dedicated-cluster-pl.bootstrap_endpoint)[0], "glb.", "")
}

data "aws_vpc" "privatelink" {
  id = var.vpc_id
}

data "aws_availability_zone" "privatelink" {
  for_each = var.subnets_to_privatelink
  zone_id  = each.key
}

locals {
  bootstrap_prefix = split(".", confluent_kafka_cluster.dedicated-cluster-pl.bootstrap_endpoint)[0]
}

resource "aws_security_group" "privatelink" {
  # Ensure that SG is unique, so that this module can be used multiple times within a single VPC
  name        = "ccloud-privatelink_${local.bootstrap_prefix}_${var.vpc_id}"
  description = "Confluent Cloud Private Link minimal security group for ${confluent_kafka_cluster.dedicated-cluster-pl.bootstrap_endpoint} in ${var.vpc_id}"
  vpc_id      = data.aws_vpc.privatelink.id

  ingress {
    # only necessary if redirect support from http/https is desired
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.privatelink.cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.privatelink.cidr_block]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.privatelink.cidr_block]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_endpoint" "privatelink" {
  vpc_id            = data.aws_vpc.privatelink.id
  service_name      = confluent_network.private-link.aws[0].private_link_endpoint_service
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.privatelink.id,
  ]

  subnet_ids          = [for zone, subnet_id in var.subnets_to_privatelink : subnet_id]
  private_dns_enabled = false
}

resource "aws_route53_zone" "privatelink" {
  name = local.hosted_zone
  comment = "privatelink purbon"

  vpc {
    vpc_id = data.aws_vpc.privatelink.id
  }
}

resource "aws_route53_record" "privatelink" {
  count   = length(var.subnets_to_privatelink) == 1 ? 0 : 1
  zone_id = aws_route53_zone.privatelink.zone_id
  name    = "*.${aws_route53_zone.privatelink.name}"
  type    = "CNAME"
  ttl     = "60"
  records = [
    aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"]
  ]
}

locals {
  endpoint_prefix = split(".", aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"])[0]
}

resource "aws_route53_record" "privatelink-zonal" {
  for_each = var.subnets_to_privatelink

  zone_id = aws_route53_zone.privatelink.zone_id
  name    = length(var.subnets_to_privatelink) == 1 ? "*" : "*.${each.key}"
  type    = "CNAME"
  ttl     = "60"
  records = [
    format("%s-%s%s",
      local.endpoint_prefix,
      data.aws_availability_zone.privatelink[each.key].name,
      replace(aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"], local.endpoint_prefix, "")
    )
  ]
}
