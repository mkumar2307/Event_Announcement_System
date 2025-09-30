variable "region" {
  default = "eu-north-1"
}

variable "email_subscription" {
  description = "Email to subscribe to SNS notifications"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket to store Lambda zip"
  type        = string
}

variable "lambda_zip_key" {
  description = "S3 object key for Lambda zip"
  type        = string
}
