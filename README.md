# terraform-aws-kms

Terraform module for managing AWS KMS keys with support for multi-region replication, automatic key rotation, custom policies, aliases, grants, and CloudWatch alarms.

## Features

- **KMS Key Creation** -- Create symmetric or asymmetric KMS keys with configurable key specs and usage types.
- **Automatic Key Rotation** -- Enable automatic key rotation with a configurable rotation period (90--2560 days).
- **Multi-Region Keys** -- Create multi-region primary keys with replicas in other AWS regions for cross-region encryption.
- **Aliases** -- Assign one or more aliases to keys for easier identification and reference.
- **Key Policies** -- Attach custom IAM policy documents to keys for fine-grained access control.
- **Grants** -- Create KMS grants for temporary, programmatic access delegation.
- **CloudWatch Alarms** -- Monitor key usage with CloudWatch metric alarms.

## Usage

### Basic

```hcl
module "kms" {
  source = "kogunlowo123/kms/aws"

  description = "Application encryption key"

  aliases = [
    "alias/my-app-key"
  ]

  tags = {
    Environment = "production"
  }
}
```

### Multi-Region with Custom Policy

```hcl
module "kms" {
  source = "kogunlowo123/kms/aws"

  providers = {
    aws         = aws
    aws.replica = aws.us_west_2
  }

  description    = "Multi-region encryption key"
  multi_region   = true
  replica_region = "us-west-2"

  key_policy = data.aws_iam_policy_document.kms_policy.json

  aliases = [
    "alias/my-app-key"
  ]
}
```

## Per-Service Key Strategy

It is recommended to create **separate KMS keys for each AWS service or workload** rather than sharing a single key across services. This approach provides several benefits:

1. **Least-privilege access** -- Each key policy can be scoped to only the principals and services that need it, reducing the blast radius of a compromised credential.

2. **Independent rotation** -- Keys can be rotated on different schedules depending on the sensitivity of each workload.

3. **Audit granularity** -- CloudTrail logs are easier to parse when each service has its own key. You can quickly identify which service performed which cryptographic operation.

4. **Blast radius containment** -- If a key is accidentally deleted or disabled, only the service associated with that key is affected.

5. **Compliance alignment** -- Many compliance frameworks (SOC 2, PCI-DSS, HIPAA) require or recommend dedicated encryption keys per data classification or workload.

### Recommended naming convention

Use aliases that encode the service, environment, and purpose:

```
alias/<environment>-<service>-<purpose>
```

Examples:

| Alias                          | Purpose                          |
|--------------------------------|----------------------------------|
| `alias/prod-s3-data-at-rest`  | S3 bucket encryption             |
| `alias/prod-rds-encryption`   | RDS instance encryption          |
| `alias/prod-lambda-env-vars`  | Lambda environment variables     |
| `alias/prod-sqs-message`      | SQS message encryption           |
| `alias/prod-secrets-manager`  | Secrets Manager secret encryption|

### Example: Per-service key setup

```hcl
module "kms_s3" {
  source      = "kogunlowo123/kms/aws"
  description = "KMS key for S3 bucket encryption"
  aliases     = ["alias/prod-s3-data-at-rest"]
  tags        = { Service = "s3" }
}

module "kms_rds" {
  source      = "kogunlowo123/kms/aws"
  description = "KMS key for RDS encryption"
  aliases     = ["alias/prod-rds-encryption"]
  tags        = { Service = "rds" }
}
```

## Requirements

| Name      | Version |
|-----------|---------|
| terraform | >= 1.0  |
| aws       | >= 5.0  |

## Inputs

| Name                       | Description                                                              | Type           | Default              | Required |
|----------------------------|--------------------------------------------------------------------------|----------------|----------------------|----------|
| description                | The description of the KMS key                                          | `string`       | `"KMS key managed by Terraform"` | no |
| key_usage                  | Intended use of the key                                                  | `string`       | `"ENCRYPT_DECRYPT"`  | no       |
| customer_master_key_spec   | Key spec (symmetric/asymmetric)                                          | `string`       | `"SYMMETRIC_DEFAULT"`| no       |
| enable_key_rotation        | Enable automatic key rotation                                            | `bool`         | `true`               | no       |
| rotation_period_in_days    | Days between automatic rotations (90--2560)                              | `number`       | `365`                | no       |
| deletion_window_in_days    | Days before permanent deletion (7--30)                                   | `number`       | `30`                 | no       |
| multi_region               | Whether to create a multi-region key                                     | `bool`         | `false`              | no       |
| replica_region             | Region for the replica key                                               | `string`       | `null`               | no       |
| aliases                    | List of alias names (must start with `alias/`)                           | `list(string)` | `[]`                 | no       |
| key_policy                 | Custom JSON key policy document                                          | `string`       | `null`               | no       |
| grants                     | List of grant objects                                                    | `list(object)` | `[]`                 | no       |
| enable_cloudwatch_alarms   | Create CloudWatch alarms for key usage                                   | `bool`         | `true`               | no       |
| tags                       | Map of tags to assign to resources                                       | `map(string)`  | `{}`                 | no       |

## Outputs

| Name              | Description                                      |
|-------------------|--------------------------------------------------|
| key_id            | The globally unique identifier for the KMS key   |
| key_arn           | The ARN of the KMS key                           |
| alias_arns        | Map of alias names to their ARNs                 |
| replica_key_arns  | List of ARNs of replica KMS keys                 |

## Examples

- [Basic](examples/basic/) -- Simple KMS key with an alias.
- [Advanced](examples/advanced/) -- KMS key with custom policy, grants, and CloudWatch alarms.
- [Complete](examples/complete/) -- Multi-region key with replicas, grants, aliases, and full configuration.

## License

MIT License. See [LICENSE](LICENSE) for details.
