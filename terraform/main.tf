module "tfstate_backend" {
  source                             = "cloudposse/tfstate-backend/aws"
  version                            = "~>1.4.0"
  enabled                            = true
  force_destroy                      = true
  attributes                         = ["update-aws-ip-ranges-lambda", "tfstate"]
  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
