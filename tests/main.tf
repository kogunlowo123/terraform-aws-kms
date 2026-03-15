terraform {
  required_version = ">= 1.7.0"
}

module "test" {
  source = "../"

  description              = "Test KMS key for module validation"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  rotation_period_in_days  = 365
  deletion_window_in_days  = 7
  aliases                  = ["alias/test-key"]

  tags = {
    Environment = "test"
    Module      = "terraform-aws-kms"
  }
}
