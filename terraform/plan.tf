terraform {
  backend "s3" {
  }
}

variable "region" {
  description = "aws cli region"
}

variable "profile" {
  description = "aws cli profile"
}

provider "aws" {
  region = "${var.region}"
  profile = "${var.profile}"
}

resource "aws_sns_topic" "inventory-db-read-scale" {
  name = "inventory-db-read-scale"
  display_name = "Inventory Database Read Cluster Scaling"
}
