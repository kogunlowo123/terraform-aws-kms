provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "replica"
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}

# Custom key policy for fine-grained access control
data "aws_iam_policy_document" "key_policy" {
  statement {
    sid    = "EnableRootAccountFullAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowS3ServiceUsage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = ["*"]
  }
}

module "kms" {
  source = "../../"

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }

  description              = "Complete multi-region KMS key with all features"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  rotation_period_in_days  = 365
  deletion_window_in_days  = 30
  multi_region             = true
  replica_region           = "us-west-2"

  key_policy = data.aws_iam_policy_document.key_policy.json

  aliases = [
    "alias/my-app-complete",
    "alias/my-app-complete-s3",
    "alias/my-app-complete-rds",
  ]

  grants = [
    {
      name               = "s3-service-grant"
      grantee_principal  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/S3ServiceRole"
      operations         = ["Encrypt", "Decrypt", "GenerateDataKey"]
      retiring_principal = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
    },
    {
      name              = "rds-service-grant"
      grantee_principal = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RDSServiceRole"
      operations        = ["Encrypt", "Decrypt"]
    },
  ]

  enable_cloudwatch_alarms = true

  tags = {
    Environment = "production"
    Project     = "example"
    CostCenter  = "12345"
  }
}

output "key_id" {
  value = module.kms.key_id
}

output "key_arn" {
  value = module.kms.key_arn
}

output "alias_arns" {
  value = module.kms.alias_arns
}

output "replica_key_arns" {
  value = module.kms.replica_key_arns
}
