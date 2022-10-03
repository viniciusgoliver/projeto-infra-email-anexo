resource "aws_sns_topic" "sns_attatch" {
  name  = "SNS_ATTATCH"
  display_name = "SNS_ATTATCH"

  tags = {
    Environment = "development"
    Type        = "sns"
  }

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish"
      ],
      "Resource": "*"      
    }
  ]
}
POLICY
}

resource "aws_sqs_queue" "sqs_attatch" {
  name                       = "SQS_ATTATCH"
  delay_seconds              = 1
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 1
  visibility_timeout_seconds = 930

  tags = {
    Environment = "development"
    Type        = "sqs"
  }
}

resource "aws_sns_topic_subscription" "sns_sqs_target" {
  topic_arn = aws_sns_topic.sns_attatch.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs_attatch.arn
}

resource "aws_sqs_queue_policy" "policy_sns_sqs_delivery" {
  queue_url = aws_sqs_queue.sqs_attatch.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "aws_sqs_queue_policy_sid",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.sqs_attatch.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.sns_attatch.arn}"
        }
      }
    }
  ]
}
POLICY
}

data "aws_lambda_function" "aws_lambda_consumer" {
  function_name = "fn_service_consumer_name"
}

resource "aws_lambda_event_source_mapping" "trigger_sqs_consumer_lambda" {
  event_source_arn = aws_sqs_queue.sqs_attatch.arn
  function_name    = data.aws_lambda_function.aws_lambda_consumer.arn
  batch_size       = var.aws_lambda_trigger_batchsize
}
