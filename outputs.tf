output "key_id" {
  description = "The globally unique identifier for the KMS key."
  value       = aws_kms_key.this.key_id
}

output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS key."
  value       = aws_kms_key.this.arn
}

output "alias_arns" {
  description = "A map of alias names to their ARNs."
  value       = { for k, v in aws_kms_alias.this : k => v.arn }
}

output "replica_key_arns" {
  description = "A list of ARNs of the replica KMS keys."
  value       = [for r in aws_kms_replica_key.this : r.arn]
}
