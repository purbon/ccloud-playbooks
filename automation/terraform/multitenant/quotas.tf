resource "confluent_kafka_client_quota" "app" {
  display_name = "app-quota"
  description  = "My App ingress and egress quotas"
  throughput {
    ingress_byte_rate = "200"
    egress_byte_rate  = "200"
  }
  principals = [confluent_service_account.app-consumer.id, confluent_service_account.app-producer.id]

  kafka_cluster {
    id = confluent_kafka_cluster.dedicated.id
  }
  environment {
    id = data.confluent_environment.purbon.id
  }

  lifecycle {
    prevent_destroy = false 
  }
}
