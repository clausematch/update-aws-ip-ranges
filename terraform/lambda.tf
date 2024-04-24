resource "aws_lambda_function" "update_ip_ranges" {
  # checkov:skip=CKV_AWS_50:X-ray tracing not required
  # checkov:skip=CKV_AWS_116:Code log errors on CloudWatch logs
  # checkov:skip=CKV_AWS_117:Not required to run inside a VPC
  # checkov:skip=CKV_AWS_173:Variable is not sensitive
  # checkov:skip=CKV_AWS_272:Code signer not required

  filename                       = data.archive_file.lambda_source.output_path
  source_code_hash               = filebase64sha256(data.archive_file.lambda_source.output_path)
  function_name                  = "UpdateIPRanges"
  description                    = "This Lambda function, invoked by an incoming SNS message, updates the IPv4 and IPv6 ranges with the addresses from the specified services"
  role                           = aws_iam_role.update_ip_ranges.arn
  handler                        = "update_aws_ip_ranges.lambda_handler"
  runtime                        = "python3.12"
  timeout                        = 300
  reserved_concurrent_executions = 2
  memory_size                    = 256
  architectures                  = ["arm64"]

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

resource "aws_lambda_permission" "amazon_ip_space_changed" {
  statement_id   = "AllowExecutionFromSNS"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.update_ip_ranges.function_name
  principal      = "sns.amazonaws.com"
  source_arn     = "arn:aws:sns:us-east-1:806199016981:AmazonIpSpaceChanged"
  source_account = "806199016981"
}

# Zip lambda source code.
data "archive_file" "lambda_source" {
  type = "zip"
  #source_dir  = var.src_path
  output_path = "/tmp/update_aws_ip_ranges.zip"

  source {
    filename = "update_aws_ip_ranges.py"
    content  = file("../lambda/update_aws_ip_ranges.py")
  }

  source {
    filename = "services.json"
    content  = file("../lambda/services.json")
  }
}
