provider "aws" {
  region = "us-east-1"
}

module "kms" {
  source = "../../"

  description = "Basic KMS key for general encryption"

  aliases = [
    "alias/my-app-basic"
  ]

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}

output "key_id" {
  value = module.kms.key_id
}

output "key_arn" {
  value = module.kms.key_arn
}
