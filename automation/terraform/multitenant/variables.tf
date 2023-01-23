variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_environment" {
  description = "A confluent cloud environment label"
  type        = string
}

variable "region" {
  description = "A confluent cloud region label in a cloud"
  type        = string
}
