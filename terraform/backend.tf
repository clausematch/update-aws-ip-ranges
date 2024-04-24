terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    region  = "us-east-1"
    bucket  = "update-aws-ip-ranges-lambda-tfstate"
    key     = "terraform.tfstate"
    encrypt = "true"

    dynamodb_table = "update-aws-ip-ranges-lambda-tfstate-lock"
  }
}
