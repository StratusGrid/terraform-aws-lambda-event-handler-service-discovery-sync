# terraform-aws-lambda-event-handler-service-discovery-sync
This module will deploy a lambda function which will listen for 
ecs tasks starting/stopping and add/remove them from service discovery.

NOTE: This was written for, and has only been tested with, 
tasks running in ECS Fargate with eni type network attachments.

### Example Usage:
```
module "cloudmap_sync_lambda" {
  source   = "StratusGrid/lambda-event-handler-service-discovery-sync/aws"
  version  = "2.0.0"
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
