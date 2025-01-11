# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "s3_bucket_notification" {
  bucket = "s3-bucket-notification-test-us-east-1"
}

resource "aws_sqs_queue" "s3-notifications-sqs" {
  name = "s3-notifications-sqs"
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "sqs:SendMessage",
        "Resource": "arn:aws:sqs:*:*:s3-notifications-sqs",
        "Condition": {
          "ArnEquals": {
           "aws:SourceArn":     
              "${aws_s3_bucket.s3_bucket_notification.arn}" 
           }
        }
      }
    ]
  }
  POLICY
}

resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = aws_s3_bucket.s3_bucket_notification.id

  queue {
    events    = ["s3:ObjectCreated:*"]
    queue_arn = aws_sqs_queue.s3-notifications-sqs.arn
    filter_prefix = "metrics/"
  }
}