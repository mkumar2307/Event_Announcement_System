provider "aws" {
  region = var.region
}

# SNS Topic
resource "aws_sns_topic" "event_topic" {
  name = "EventAnnouncements"
}

# SNS Subscription
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.event_topic.arn
  protocol  = "email"
  endpoint  = var.email_subscription
}

# DynamoDB Table
resource "aws_dynamodb_table" "event_table" {
  name         = "EventTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_event_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_event_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["sns:Publish"]
        Resource = aws_sns_topic.event_topic.arn
      },
      {
        Effect = "Allow"
        Action = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.event_table.arn
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "announce_event" {
  function_name = "AnnounceEventFunction"
  s3_bucket     = var.s3_bucket
  s3_key        = var.lambda_zip_key
  handler       = "app.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.event_topic.arn
      DYNAMODB_TABLE = aws_dynamodb_table.event_table.name
    }
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "event_api" {
  name = "EventApi"
}

resource "aws_api_gateway_resource" "events_resource" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  parent_id   = aws_api_gateway_rest_api.event_api.root_resource_id
  path_part   = "events"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  resource_id   = aws_api_gateway_resource.events_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  resource_id = aws_api_gateway_resource.events_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.announce_event.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.announce_event.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.event_api.execution_arn}/*/*"
}
