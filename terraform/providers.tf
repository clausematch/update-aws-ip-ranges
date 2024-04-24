# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  profile = local.profile
}

# provider to manage SNS topics
provider "aws" {
  alias  = "sns"
  region = "us-east-1"
  profile = local.profile
}