resource "aws_kms_key" "this" {
  description              = var.description
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  deletion_window_in_days  = var.deletion_window_in_days
  is_enabled               = true
  enable_key_rotation      = var.enable_key_rotation
  rotation_period_in_days  = var.enable_key_rotation ? var.rotation_period_in_days : null
  multi_region             = var.multi_region
  policy                   = coalesce(var.key_policy, data.aws_iam_policy_document.default_key_policy.json)

  tags = var.tags
}

resource "aws_kms_alias" "this" {
  for_each = { for alias in var.aliases : alias => alias }

  name          = each.value
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_replica_key" "this" {
  count = var.multi_region && var.replica_region != null ? 1 : 0

  provider = aws.replica

  primary_key_arn         = aws_kms_key.this.arn
  description             = "${var.description} (replica)"
  deletion_window_in_days = var.deletion_window_in_days
  enabled                 = true
  policy                  = coalesce(var.key_policy, data.aws_iam_policy_document.default_key_policy.json)

  tags = var.tags
}

resource "aws_kms_grant" "this" {
  for_each = { for idx, grant in var.grants : coalesce(grant.name, "grant-${idx}") => grant }

  name              = each.key
  key_id            = aws_kms_key.this.key_id
  grantee_principal = each.value.grantee_principal
  operations        = each.value.operations
  retiring_principal = each.value.retiring_principal

  dynamic "constraints" {
    for_each = each.value.constraints != null ? [each.value.constraints] : []

    content {
      encryption_context_equals = constraints.value.encryption_context_equals
      encryption_context_subset = constraints.value.encryption_context_subset
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "key_usage" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "kms-key-usage-${aws_kms_key.this.key_id}"
  alarm_description   = "Alarm when KMS key ${aws_kms_key.this.key_id} exceeds usage threshold"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "KeyUsage"
  namespace           = "AWS/KMS"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000
  treat_missing_data  = "notBreaching"

  dimensions = {
    KeyId = aws_kms_key.this.key_id
  }

  tags = var.tags
}
