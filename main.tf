terraform {
  required_version = ">= 0.12.2"
  backend "s3" {
    bucket = "bucket-nme"
    key    = "dir/aws-info"
    region = "us-east-1"
  }
}
provider "aws" {
  profile = "default"
  version = "~> 3.0"
  region = "eu-west-1"
}

provider "local" {
  version = "~> 1.2"
}

locals {
}
##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################

data "aws_vpc" "default" {
  id = "vpc_id"
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
  tags = {
    "Reach" = "public"
  }
}
resource "aws_security_group" "dev_sg" {
  name        = "developers-ips"
  description = "Security group for developers IPs"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"        = "developers-ips"
    "Application" = "",
    "BU" = "",
    "Client" = "Manulife",
    "Environment" = terraform.workspace,
    "Project" = "project-nme",
    "Segment" = "env_security_group",
    "account" = "ccount-name",
    "env" = terraform.workspace,
  }
}

resource "aws_security_group_rule" "aws_access" {
  type  = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  description = "ssh for internal IPs"
  cidr_blocks = ["10.10.0.0/16"]
  security_group_id = aws_security_group.dev_sg.id
}
resource "aws_security_group_rule" "devops_access" {
  for_each = var.devops_ips
  type  = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = ["${each.value}/32"]
  description = "${each.key} access"
  security_group_id = aws_security_group.dev_sg.id
}

resource "aws_security_group_rule" "devlopers_access" {
  for_each = var.developers_ips
  type  = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = ["${each.value}/32"]
  description = "${each.key} access"
  security_group_id = aws_security_group.dev_sg.id
}
resource "aws_security_group_rule" "devlopers_access_v6" {
  for_each = var.developers_ipv6
  type  = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  ipv6_cidr_blocks = ["${each.value}/128"]
  description = "${each.key} access"
  security_group_id = aws_security_group.dev_sg.id
}

resource "aws_security_group_rule" "client_80" {
  for_each = var.client_ips
  type  = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["${each.value}/32"]
  description = "${each.key} http access"
  security_group_id = aws_security_group.dev_sg.id
}
resource "aws_security_group_rule" "client_443" {
  for_each = var.client_ips
  type  = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["${each.value}/32"]
  description = "${each.key} https access"
  security_group_id = aws_security_group.dev_sg.id
}

resource "aws_security_group_rule" "client_80_cidr" {
  for_each = var.client_cidrs
  type  = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [each.value]
  description = "${each.key} access"
  security_group_id = aws_security_group.dev_sg.id
}
resource "aws_security_group_rule" "client_443_cidr" {
  for_each = var.client_cidrs
  type  = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [each.value]
  description = "${each.key} access"
  security_group_id = aws_security_group.dev_sg.id
}

