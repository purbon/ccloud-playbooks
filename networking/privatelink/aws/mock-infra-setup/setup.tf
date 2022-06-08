# EU (Ireland)  eu-west-1
# EU (London) eu-west-2
# EU (Frankfurt) eu-central-1


variable "region" {
  default = "eu-west-1"
}

variable "Owner_Name" {
  default = "Pere Urbon"
}


variable "Owner_Email" {
  default = "pere@confluent.io"
}

variable "ownershort" {
  default = "pub"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "myips" {
  type    = list(string)
  default = []
}

variable "root_username" {
  default = "foo"
}
variable "root_password" {
  default = "foobarbaz"
}

module "ireland-cluster" {
  source         = "./is-module"
  name           = "ireland-cluster"
  region         = "eu-west-1"
  azs            = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  Owner_Name     = var.Owner_Name
  Owner_Email    = var.Owner_Email
  key_name       = "purbon-ireland-sa"
  myips          = var.myips
  ownershort     = var.ownershort
}
