# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-07

### Added

- Initial release of the terraform-aws-kms module.
- KMS key creation with configurable key usage and key spec.
- Automatic key rotation with configurable rotation period.
- Multi-region key support with replica key resource.
- KMS alias management with support for multiple aliases per key.
- Custom key policy support via JSON policy documents.
- KMS grant management with support for constraints.
- CloudWatch metric alarm for key usage monitoring.
- Basic, advanced, and complete usage examples.
