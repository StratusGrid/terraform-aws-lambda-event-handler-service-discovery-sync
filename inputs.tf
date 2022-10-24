variable "name_prefix" {
  description = "String to prefix on object names"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "String to append to object names. This is optional, so start with dash if using"
  type        = string
  default     = ""
}

variable "unique_name" {
  description = "Unique string to describe resources. E.g. 'ebs-append' would make <prefix><name>(type)<suffix>"
  type        = string
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default = {
    Developer   = "StratusGrid"
    Provisioner = "Terraform"
  }
}

variable "ecs_cluster_arns" {
  description = "List of ecs cluster ARNS you want to listen to events from"
  type        = list(any)
}

variable "task_definition_matcher" {
  description = "String to use as regex string when matching ARN of task definitions to determine if it is in scope"
  type        = string
}

variable "service_id" {
  description = "ID of service discovery name being targeted, like srv-p6whu8o2dm7xmlc3"
  type        = string
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days for retention period of Lambda logs"
  type        = string
  default     = "30"
}

