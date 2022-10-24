locals {
  kms_allowed_accounts = compact([data.aws_caller_identity.current.account_id])
}

#Event rule to direct events to the Lambda Function

resource "aws_cloudwatch_event_rule" "event" {
  name        = "${var.name_prefix}-${var.unique_name}-rule${var.name_suffix}"
  description = "Pattern of events to forward to targets"

  event_pattern = jsonencode(
    {
      "source" : [
        "aws.ecs"
      ],
      "detail-type" : [
        "ECS Task State Change"
      ],
      "detail" : {
        "lastStatus" : [
          "STOPPED",
          "RUNNING"
        ],
        "clusterArn" : var.ecs_cluster_arns
      }
    }
  )
}

#Target to direct event at function
resource "aws_cloudwatch_event_target" "function_target" {
  rule      = aws_cloudwatch_event_rule.event.name
  target_id = "${var.name_prefix}-${var.unique_name}-target${var.name_suffix}"
  arn       = aws_lambda_function.function.arn
}

#Permission to allow event trigger
resource "aws_lambda_permission" "allow_cloudwatch_event_trigger" {
  statement_id  = "TrustCWEToInvokeMyLambdaFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event.arn
}

#Automatic packaging of code
data "archive_file" "function_code" {
  type        = "zip"
  source_dir  = "${path.module}/function_code"
  output_path = "${path.module}/function_code_zipped/function_code.zip"
}

#Function to process event
resource "aws_lambda_function" "function" {
  filename         = data.archive_file.function_code.output_path
  source_code_hash = filebase64sha256(data.archive_file.function_code.output_path)
  function_name    = "${var.name_prefix}-${var.unique_name}-function${var.name_suffix}"
  role             = aws_iam_role.function_role.arn
  handler          = "main.handler"
  runtime          = "python3.6"
  timeout          = "10"
  environment {
    variables = {
      task_definition_matcher = var.task_definition_matcher
      service_id              = var.service_id
    }
  }
  tracing_config {
    mode = "Active"
  }
  lifecycle {
    ignore_changes = [last_modified]
  }
  tags = var.input_tags
}

#Role to attach policy to Function
resource "aws_iam_role" "function_role" {
  name = "${var.name_prefix}-${var.unique_name}-role${var.name_suffix}"
  tags = var.input_tags

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

#Default policy for Lambda to be executed and put logs in Cloudwatch
resource "aws_iam_role_policy" "function_policy_default" {
  name = "${var.name_prefix}-${var.unique_name}-policy-default${var.name_suffix}"
  role = aws_iam_role.function_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowListCloudWatchLogGroups",
      "Effect": "Allow",
      "Action": "logs:DescribeLogStreams",
      "Resource": "arn:aws:logs:us-east-1:*:*"
    },
    {
      "Sid": "AllowCreatePutLogGroupsStreams",
      "Effect": "Allow",
      "Action": [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
      ],
      "Resource": [
          "arn:aws:logs:${data.aws_region.current.name}:*:log-group:/aws/lambda/${aws_lambda_function.function.function_name}",
          "arn:aws:logs:${data.aws_region.current.name}:*:log-group:/aws/lambda/${aws_lambda_function.function.function_name}:log-stream:*"
      ]
    }
  ]
}
EOF

}

#Policy for additional Permissions for Lambda Execution
resource "aws_iam_role_policy" "function_policy" {
  name = "${var.name_prefix}-${var.unique_name}-policy${var.name_suffix}"
  role = aws_iam_role.function_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowServiceDiscoveryActions",
      "Effect": "Allow",
      "Action": [
          "servicediscovery:RegisterInstance",
          "servicediscovery:deregisterInstance"
      ],
      "Resource": "arn:aws:servicediscovery:${data.aws_region.current.name}:*:service/${var.service_id}"
    }
  ]
}
EOF

}

#Cloudwatch Log Group for Function
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.function.function_name}"
  kms_key_id        = aws_kms_key.this
  retention_in_days = var.cloudwatch_log_retention_days

  tags = var.input_tags
}

resource "aws_kms_key" "this" {
  description         = "Key used to encrypt this module"
  policy              = data.aws_iam_policy_document.this.json
  enable_key_rotation = true
}
