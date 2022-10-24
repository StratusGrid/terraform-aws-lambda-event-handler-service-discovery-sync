<!-- BEGIN_TF_DOCS -->
# terraform-aws-lambda-event-handler-service-discovery-sync
GitHub: [StratusGrid/terraform-aws-lambda-event-handler-service-discovery-sync](https://github.com/StratusGrid/terraform-aws-lambda-event-handler-service-discovery-sync)
## Example
```hcl
module "cloudmap_sync_lambda" {
  source   = "StratusGrid/lambda-event-handler-service-discovery-sync/aws"
  version  = "1.0.0"
  # source   = "github.com/StratusGrid/terraform-aws-lambda-event-handler-service-discovery-sync"

  name_prefix             = var.name_prefix
  name_suffix             = local.name_suffix
  unique_name             = "event-handler-cpu-credit-balance"
  ecs_cluster_arns        = [module.ecs_fargate_1.ecs_cluster_arn, module.ecs_fargate_2.ecs_cluster_arn]
  task_definition_matcher = "my-application-"
  service_id              = aws_service_discovery_service.this.id
  input_tags              = merge(local.common_tags, {})
}
```
## StratusGrid Standards we assume
- All resource names and name tags shall use `_` and not `-`s
- The old naming standard for common files such as inputs, outputs, providers, etc was to prefix them with a `-`, this is no longer true as it's not POSIX compliant. Our pre-commit hooks will fail with this old standard.
- StratusGrid generally follows the TerraForm standards outlined [here](https://www.terraform-best-practices.com/naming)
## Repo Knowledge
This module will deploy a lambda function which will listen for ecs tasks starting/stopping and add/remove them from service discovery.
NOTE: This was written for, and has only been tested with, tasks running in ECS Fargate with eni type network attachments.
## Documentation
This repo is self documenting via Terraform Docs, please see the note at the bottom.
### `LICENSE`
This is the standard Apache 2.0 License as defined [here](https://stratusgrid.atlassian.net/wiki/spaces/TK/pages/2121728017/StratusGrid+Terraform+Module+Requirements).
### `outputs.tf`
The StratusGrid standard for Terraform Outputs.
### `README.md`
It's this file! I'm always updated via TF Docs!
### `tags.tf`
The StratusGrid standard for provider/module level tagging. This file contains logic to always merge the repo URL.
### `variables.tf`
All variables related to this repo for all facets.
One day this should be broken up into each file, maybe maybe not.
### `versions.tf`
This file contains the required providers and their versions. Providers need to be specified otherwise provider overrides can not be done.
## Documentation of Misc Config Files
This section is supposed to outline what the misc configuration files do and what is there purpose
### `.config/.terraform-docs.yml`
This file auto generates your `README.md` file.
### `.github/workflows/pre-commit.yml`
This file contains the instructions for Github workflows, in specific this file run pre-commit and will allow the PR to pass or fail. This is a safety check and extras for if pre-commit isn't run locally.
### `examples/*`
The files in here are used by `.config/terraform-docs.yml` for generating the `README.md`. All files must end in `.tfnot` so Terraform validate doesn't trip on them since they're purely example files.
### `.gitignore`
This is your gitignore, and contains a slew of default standards.
---
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |
## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.function_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.function_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.function_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.function_policy_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_cloudwatch_event_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | Number of days for retention period of Lambda logs | `string` | `"30"` | no |
| <a name="input_ecs_cluster_arns"></a> [ecs\_cluster\_arns](#input\_ecs\_cluster\_arns) | List of ecs cluster ARNS you want to listen to events from | `list(any)` | n/a | yes |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to resources | `map(string)` | <pre>{<br>  "Developer": "StratusGrid",<br>  "Provisioner": "Terraform"<br>}</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | String to prefix on object names | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | String to append to object names. This is optional, so start with dash if using | `string` | `""` | no |
| <a name="input_service_id"></a> [service\_id](#input\_service\_id) | ID of service discovery name being targeted, like srv-p6whu8o2dm7xmlc3 | `string` | n/a | yes |
| <a name="input_task_definition_matcher"></a> [task\_definition\_matcher](#input\_task\_definition\_matcher) | String to use as regex string when matching ARN of task definitions to determine if it is in scope | `string` | n/a | yes |
| <a name="input_unique_name"></a> [unique\_name](#input\_unique\_name) | Unique string to describe resources. E.g. 'ebs-append' would make <prefix><name>(type)<suffix> | `string` | n/a | yes |
## Outputs

No outputs.
---
Note, manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml`
<!-- END_TF_DOCS -->