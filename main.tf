data "aws_caller_identity" "current" {}

/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["eu-west-1b", "eu-west-1c"]
}

provider "aws" {
  region = "${var.region}"

  #profile = "duduribeiro"
}

resource "aws_key_pair" "key" {
  key_name   = "${var.env}-node_app_key"
  public_key = "${file("node-hello-key.pub")}"
}

module "networking" {
  source               = "./modules/networking"
  environment          = "${var.env}"
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
  region               = "${var.region}"
  availability_zones   = "${local.production_availability_zones}"
  key_name             = "node_app_key"
}

module "ecs" {
  source             = "./modules/ecs"
  environment        = "${var.env}"
  vpc_id             = "${module.networking.vpc_id}"
  availability_zones = "${local.production_availability_zones}"
  repository_url    = "XXXXXXXXXXXX.dkr.ecr.eu-west-1.amazonaws.com/node-hello-app"
  subnets_ids        = ["${module.networking.private_subnets_id}"]
  public_subnet_ids  = ["${module.networking.public_subnets_id}"]

  security_groups_ids = [
    "${module.networking.security_groups_ids}",
  ]
}

terraform {
  backend "s3" {
    bucket         = "node-hello-budayabanu-eu-west-1"
    region         = "eu-west-1"
    dynamodb_table = "node-hello-budayabanu-eu-west-1"
  }
}
