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

variable "build" {
  description = "function build num"
}

variable "cluster" {
  description = "rds cluster name"
}

variable "alarms" {
  description = "alarms defining scaling conditions"
  type = "list"
}

provider "aws" {
  region = "${var.region}"
  profile = "${var.profile}"
}

resource "aws_sns_topic" "topic" {
  name = "inventory-db-read-scale"
  display_name = "Inventory Database Read Cluster Scaling"
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  count               = "${length(var.alarms)}"
  alarm_name          = "inventory-db-read-scale-${count.index}-${lookup(var.alarms[count.index], "do")}"
  comparison_operator = "${lookup(var.alarms[count.index], "comparison")}"
  evaluation_periods  = "12"
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "${lookup(var.alarms[count.index], "threshold")}"

  dimensions {
    Role = "READER"
    DBClusterIdentifier = "${var.cluster}"
  }

  alarm_description = "inventory database read cluster scaling alarm"
  alarm_actions = ["${aws_sns_topic.topic.arn}"]
}

resource "aws_lambda_function" "report" {
  function_name = "inventory-db-read-scale-report"
  handler = "main.handle"
  runtime = "python3.6"
  filename = "/tmp/${var.build}/report.zip"
  source_code_hash = "${base64sha256(file("/tmp/${var.build}/report.zip"))}"
  role = "${aws_iam_role.role.arn}"
}

resource "aws_iam_role" "role" {
  name = "inventory-db-read-scale"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.report.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.topic.arn}"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = "${aws_sns_topic.topic.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.report.arn}"
}


resource "aws_iam_role_policy" "policy" {
  name = "inventory-db-read-scale-policy"
  role = "${aws_iam_role.role.id}"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}
