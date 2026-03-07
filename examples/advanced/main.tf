provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

# A custom key policy that grants the root account full access
# and allows an IAM role to use the key for encryption/decryption.
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
    sid    = "AllowServiceRoleUsage"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/MyServiceRole"]
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

  description             = "Advanced KMS key with custom policy and grants"
  enable_key_rotation     = true
  rotation_period_in_days = 180
  deletion_window_in_days = 14

  key_policy = data.aws_iam_policy_document.key_policy.json

  aliases = [
    "alias/my-app-advanced",
    "alias/my-app-advanced-secondary",
  ]

  grants = [
    {
      grantee_principal  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/MyServiceRole"
      operations         = ["Encrypt", "Decrypt", "GenerateDataKey"]
      retiring_principal = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
    },
  ]

  enable_cloudwatch_alarms = true

  tags = {
    Environment = "staging"
    Project     = "example"
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
