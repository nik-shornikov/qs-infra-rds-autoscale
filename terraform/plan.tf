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

variable "cluster" {
  description = "rds cluster name"
}

provider "aws" {
  region = "${var.region}"
  profile = "${var.profile}"
}

resource "aws_sns_topic" "inventory-db-read-scale" {
  name = "inventory-db-read-scale"
  display_name = "Inventory Database Read Cluster Scaling"
}

resource "aws_cloudwatch_metric_alarm" "rds-credits-low" {
  alarm_name          = "rds-credits-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "110"

  dimensions {
    Role = "READER"
    DBClusterIdentifier = "${var.cluster}"
  }

  alarm_description = "this alarm goes off when a read cluster machine dips in credits"
}
