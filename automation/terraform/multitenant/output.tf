output "app-no-perm-display_name" {
  value = confluent_service_account.app-no-perm.display_name
}

output "app-no-perm-api-key" {
  value = confluent_api_key.app-no-perm-kafka-api-key.id
}

output "app-no-perm-api-key-secret" {
  value = confluent_api_key.app-no-perm-kafka-api-key.secret
  sensitive = true
}
