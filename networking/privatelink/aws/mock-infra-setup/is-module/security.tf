
resource "aws_vpc" "ccloud_purbon_test" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "ps_ccloud_purbon_test"
  }
}

resource "aws_subnet" "ccloud_purbon_test" {
  count      = 3
  vpc_id     = aws_vpc.ccloud_purbon_test.id
  cidr_block = "10.0.${10+count.index}.0/24"
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.ownershort}-vpc-subnet-ccloud-${element(var.azs, count.index)}"
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ccloud_purbon_test.id

  tags = {
      Name = "${var.ownershort}-vpc-gw"
      Owner_Name = var.Owner_Name
      Owner_Email = var.Owner_Email
  }
}

resource "aws_default_route_table" "bootcamp_vpc_route_table" {
  default_route_table_id = aws_vpc.ccloud_purbon_test.default_route_table_id

  #route {
  #  cidr_block = "10.0.0.0/16"
  #  gateway_id = aws_internet_gateway.example.id
  #}

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.ownershort}-vpc-default-routing-table"
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
  }
}


#data "aws_subnet_ids" "ccloud_purbon_test_subnets" {
#  vpc_id = aws_vpc.ccloud_purbon_test.id
#}


resource "aws_security_group" "jumphost" {
  description = "purbon jumphost - Managed by Terraform"
  name = "${var.ownershort}-jumphost"

  tags = {
    Name = "${var.ownershort}-jumphost"
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
  }

  vpc_id = aws_vpc.ccloud_purbon_test.id

   # cluster
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
  }
}

resource "aws_security_group" "restproxy" {
  description = "purbon restproxy - Managed by Terraform"
  name = "${var.ownershort}-restproxy"

  tags = {
    Name = "${var.ownershort}-restproxy"
    Owner_Name = var.Owner_Name
    Owner_Email = var.Owner_Email
  }

  vpc_id = aws_vpc.ccloud_purbon_test.id

   # cluster
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
  }

  dynamic "ingress" {
    for_each = local.myip-cidrs
    content {
      from_port = 80
      to_port = 80
      protocol = "TCP"
      self = true
      cidr_blocks = ["${ingress.value}"]
    }
  }

  dynamic "ingress" {
    for_each = local.myip-cidrs
    content {
      from_port = 443
      to_port = 443
      protocol = "TCP"
      self = true
      cidr_blocks = ["${ingress.value}"]
    }
  }

}

resource "aws_security_group" "ssh" {
  description = "Managed by Terraform"
  name = "${var.ownershort}-ssh"

  vpc_id = aws_vpc.ccloud_purbon_test.id

  dynamic "ingress" {
    for_each = local.myip-cidrs
    content {
      from_port = 8
      to_port = 0
      protocol = "icmp"
      self = true
      cidr_blocks = ["${ingress.value}"]
    }
  }


  dynamic "ingress" {
    for_each = local.myip-cidrs
    content {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      self = true
      cidr_blocks = ["${ingress.value}"]
    }
  }

  # ssh from anywhere
  ingress {
      from_port = 22
      to_port = 22
      protocol = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
