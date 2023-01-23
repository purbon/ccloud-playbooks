
variable names {
  type = list(string)
  description = "List of topic names"
  default = [ "org.tenant.orders", "org.tenant.cmds", "org.tenant.invoices" ]
}

resource "confluent_kafka_topic" "org_tenant_topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.dedicated.id
  }
  for_each = toset(var.names)
  topic_name    = each.key
  rest_endpoint = confluent_kafka_cluster.dedicated.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}
