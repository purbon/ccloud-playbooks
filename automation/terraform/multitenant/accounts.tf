resource "confluent_service_account" "app-no-perm" {
  display_name = "purbon-app-no-perm"
  description  = "Service account without any permissions in the inventory cluster"
}



resource "confluent_api_key" "app-no-perm-kafka-api-key" {
  display_name = "app-no-perm-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-no-perm' service account"
  owner {
    id          = confluent_service_account.app-no-perm.id
    api_version = confluent_service_account.app-no-perm.api_version
    kind        = confluent_service_account.app-no-perm.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.dedicated.id
    api_version = confluent_kafka_cluster.dedicated.api_version
    kind        = confluent_kafka_cluster.dedicated.kind

    environment {
      id = data.confluent_environment.purbon.id
    }
  }
}

resource "confluent_service_account" "app-consumer" {
  display_name = "purbon-app-consumer"
  description  = "Service account to consume from of 'inventory' Kafka cluster tenant topics"
}

resource "confluent_service_account" "app-producer" {
  display_name = "purbon-app-producer"
  description  = "Service account to producer from of 'inventory' Kafka cluster tenant topics"
}

resource "confluent_api_key" "app-consumer-kafka-api-key" {
  display_name = "purbon-app-consumer-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-consumer' service account"
  owner {
    id          = confluent_service_account.app-consumer.id
    api_version = confluent_service_account.app-consumer.api_version
    kind        = confluent_service_account.app-consumer.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.dedicated.id
    api_version = confluent_kafka_cluster.dedicated.api_version
    kind        = confluent_kafka_cluster.dedicated.kind

    environment {
      id = data.confluent_environment.purbon.id
    }
  }
}
