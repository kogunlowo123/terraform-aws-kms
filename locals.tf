locals {
  key_id  = aws_kms_key.this.key_id
  key_arn = aws_kms_key.this.arn

  aliases_map = { for alias in var.aliases : alias => alias }
  grants_map  = { for idx, grant in var.grants : coalesce(grant.name, "grant-${idx}") => grant }

  default_tags = merge(
    {
      "ManagedBy" = "terraform"
      "Module"    = "terraform-aws-kms"
    },
    var.tags,
  )
}
