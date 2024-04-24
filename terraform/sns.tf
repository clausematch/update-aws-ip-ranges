resource "aws_sns_topic_subscription" "amazon_ip_space_changed" {
  provider  = aws.sns
  topic_arn = "arn:aws:sns:us-east-1:806199016981:AmazonIpSpaceChanged"
  protocol  = "lambda"
  endpoint  = aws_lambda_function.update_ip_ranges.arn
}
