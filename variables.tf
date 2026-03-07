variable "description" {
  description = "The description of the KMS key."
  type        = string
  default     = "KMS key managed by Terraform"
}

variable "key_usage" {
  description = "Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT, SIGN_VERIFY, GENERATE_VERIFY_MAC."
  type        = string
  default     = "ENCRYPT_DECRYPT"

  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "key_usage must be one of: ENCRYPT_DECRYPT, SIGN_VERIFY, GENERATE_VERIFY_MAC."
  }
}

variable "customer_master_key_spec" {
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption or signing algorithms the key supports."
  type        = string
  default     = "SYMMETRIC_DEFAULT"

  validation {
    condition = contains([
      "SYMMETRIC_DEFAULT",
      "RSA_2048", "RSA_3072", "RSA_4096",
      "ECC_NIST_P256", "ECC_NIST_P384", "ECC_NIST_P521", "ECC_SECG_P256K1",
      "HMAC_224", "HMAC_256", "HMAC_384", "HMAC_512"
    ], var.customer_master_key_spec)
    error_message = "customer_master_key_spec must be a valid KMS key spec."
  }
}

variable "enable_key_rotation" {
  description = "Whether to enable automatic annual rotation of the key material."
  type        = bool
  default     = true
}

variable "rotation_period_in_days" {
  description = "The number of days between each automatic rotation. Valid value is between 90 and 2560."
  type        = number
  default     = 365

  validation {
    condition     = var.rotation_period_in_days >= 90 && var.rotation_period_in_days <= 2560
    error_message = "rotation_period_in_days must be between 90 and 2560."
  }
}

variable "deletion_window_in_days" {
  description = "The number of days before the key is permanently deleted after destruction of the resource. Must be between 7 and 30."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

variable "multi_region" {
  description = "Whether the KMS key is a multi-Region key. If true, a replica key resource is created."
  type        = bool
  default     = false
}

variable "aliases" {
  description = "A list of alias names for the KMS key. Each alias must begin with 'alias/'."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for a in var.aliases : can(regex("^alias/", a))])
    error_message = "Each alias must begin with 'alias/'."
  }
}

variable "key_policy" {
  description = "A valid JSON policy document for the KMS key. If not provided, a default policy granting the account full access is used."
  type        = string
  default     = null
}

variable "grants" {
  description = "A list of grant objects for the KMS key."
  type = list(object({
    grantee_principal    = string
    operations           = list(string)
    retiring_principal   = optional(string, null)
    name                 = optional(string, null)
    grant_creation_tokens = optional(list(string), null)
    constraints = optional(object({
      encryption_context_equals = optional(map(string), null)
      encryption_context_subset = optional(map(string), null)
    }), null)
  }))
  default = []
}

variable "enable_cloudwatch_alarms" {
  description = "Whether to create CloudWatch metric alarms for KMS key usage monitoring."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the KMS key and related resources."
  type        = map(string)
  default     = {}
}

variable "replica_region" {
  description = "The region for the replica key when multi_region is true."
  type        = string
  default     = null
}
