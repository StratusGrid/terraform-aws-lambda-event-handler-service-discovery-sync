locals {
  common_tags = merge(var.input_tags, {
    "ModuleSourceRepo" = "github.com/StratusGrid/terraform-aws-lambda-event-handler-service-discovery-sync"
  })
}