data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = local.kms_allowed_accounts
    content {
      sid    = "Enable IAM Permissions from ${statement.value}"
      effect = "Allow"
      principals {
        identifiers = ["arn:aws:iam::${statement.value}:root"]
        type        = "AWS"
      }
      actions   = ["kms:*"]
      resources = ["*"]
    }
  }
}
