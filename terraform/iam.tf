resource "aws_iam_role" "update_ip_ranges" {
  name = "update-ip-ranges-role"
  description = "Managed by update IP ranges Lambda"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )

  inline_policy {
    name = "CloudWatchLogsPermissions"

    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "logs:CreateLogGroup"
            ],
            "Resource" : "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource" : "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*update-ip-ranges*:*"
          }
        ]
      }
    )
  }

  inline_policy {
    name = "WAFPermissions"

    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "wafv2:ListIPSets"
            ],
            "Resource" : "*"
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "wafv2:CreateIPSet",
              "wafv2:TagResource"
            ],
            "Resource" : "*",
            "Condition" : {
              "StringEquals" : {
                "aws:RequestTag/UpdatedAt" : "Not yet",
                "aws:RequestTag/ManagedBy" : "update-aws-ip-ranges"
              },
              "StringLike" : {
                "aws:RequestTag/Name" : [
                  "aws-ip-ranges-*-ipv4",
                  "aws-ip-ranges-*-ipv6"
                ]
              },
              "ForAllValues:StringEquals" : {
                "aws:TagKeys" : [
                  "Name",
                  "ManagedBy",
                  "CreatedAt",
                  "UpdatedAt"
                ]
              }
            }
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "wafv2:TagResource"
            ],
            "Resource" : [
              "arn:${data.aws_partition.current.partition}:wafv2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/ipset/aws-ip-ranges-*-ipv4/*",
              "arn:${data.aws_partition.current.partition}:wafv2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/ipset/aws-ip-ranges-*-ipv6/*"
            ],
            "Condition" : {
              "StringEquals" : {
                "aws:ResourceTag/ManagedBy" : "update-aws-ip-ranges"
              },
              "StringLike" : {
                "aws:ResourceTag/Name" : [
                  "aws-ip-ranges-*-ipv4",
                  "aws-ip-ranges-*-ipv6"
                ]
              },
              "ForAllValues:StringEquals" : {
                "aws:TagKeys" : [
                  "UpdatedAt"
                ]
              }
            }
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "wafv2:ListTagsForResource",
              "wafv2:GetIPSet",
              "wafv2:UpdateIPSet"
            ],
            "Resource" : [
              "arn:${data.aws_partition.current.partition}:wafv2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/ipset/aws-ip-ranges-*-ipv4/*",
              "arn:${data.aws_partition.current.partition}:wafv2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/ipset/aws-ip-ranges-*-ipv6/*"
            ],
            "Condition" : {
              "StringEquals" : {
                "aws:ResourceTag/ManagedBy" : "update-aws-ip-ranges"
              },
              "StringLike" : {
                "aws:ResourceTag/Name" : [
                  "aws-ip-ranges-*-ipv4",
                  "aws-ip-ranges-*-ipv6"
                ]
              }
            }
          }
        ]
      }
    )
  }

  inline_policy {
    name = "EC2Permissions"

    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "ec2:DescribeTags",
              "ec2:DescribeManagedPrefixLists"
            ],
            "Resource" : "*",
            "Condition" : {
              "StringEquals" : {
                "ec2:Region" : "${data.aws_region.current.name}"
              }
            }
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "ec2:GetManagedPrefixListEntries",
              "ec2:ModifyManagedPrefixList",
              "ec2:CreateTags"
            ],
            "Resource" : "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:prefix-list/*",
            "Condition" : {
              "StringEquals" : {
                "aws:ResourceTag/ManagedBy" : "update-aws-ip-ranges",
                "ec2:Region" : "${data.aws_region.current.name}"
              },
              "StringLike" : {
                "aws:ResourceTag/Name" : [
                  "aws-ip-ranges-*-ipv4",
                  "aws-ip-ranges-*-ipv6"
                ]
              }
            }
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "ec2:CreateManagedPrefixList"
            ],
            "Resource" : "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:prefix-list/*",
            "Condition" : {
              "StringEquals" : {
                "aws:RequestTag/UpdatedAt" : "Not yet",
                "aws:RequestTag/ManagedBy" : "update-aws-ip-ranges",
                "ec2:Region" : "${data.aws_region.current.name}"
              },
              "StringLike" : {
                "aws:RequestTag/Name" : [
                  "aws-ip-ranges-*-ipv4",
                  "aws-ip-ranges-*-ipv6"
                ]
              },
              "ForAllValues:StringEquals" : {
                "aws:TagKeys" : [
                  "Name",
                  "ManagedBy",
                  "CreatedAt",
                  "UpdatedAt"
                ]
              }
            }
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "ec2:CreateTags"
            ],
            "Resource" : "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:prefix-list/*",
            "Condition" : {
              "StringEquals" : {
                "ec2:Region" : "${data.aws_region.current.name}",
                "ec2:CreateAction" : "CreateManagedPrefixList"
              }
            }
          }
        ]
      }
    )
  }
}
