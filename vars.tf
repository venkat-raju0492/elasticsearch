variable "region" {
  description = "AWS region"
}

variable "project" {
  description = "name of the project"
}

variable "env" {
  description = "name of the environment"
}

variable "cloudwatch_logs_group" {
  description = "CW logs group name"
  default     = ""
}

variable "costcategory" {
  description = "cost category"
}

variable "instance_count" {
  description = "instance count"
}

variable "instance_type" {
  description = "instance type"
}

variable "dedicated_master_count" {
  description = "dedicated master count"
}

variable "dedicated_master_type" {
  description = "dedicated master type"
}

variable "ebs_enabled" {
  description = "ebs enabled"
  type        = bool
  default     = true
}

variable "ebs_options_volume_type" {
  description = "ebs options volume type"
  type        = string
  default     = "gp2"
}

variable "ebs_options_volume_size" {
  description = "ebs options volume size"
}

variable "ebs_options_iops" {
  description = "ebs options iops"
  type        = number
  default     = 0
}

variable "subnet_ids" {
  description = "subnet ids"
}

variable "automated_snapshot_start_hour" {
  description = "automated snapshot start hour"
  default     = 23
}

variable "es_uname" {
  description = "es uname"
}

variable "tls_security_policy" {
  description = "tls security policy"
}

variable "leader_cluster" {
  description = "leader cluster"
}

variable "iam_role_name" {
  description = "iam role name"
}

variable "retention_in_days" {
  description = "retention in days"
}

variable "vpc_id" {
  description = "vpc id"
}

variable "allow_security_group_ids" {
  description = "allow security group ids"
}

variable "allowed_cidrs" {
  description = "allowed cidrs"
}

variable "ingress_rule_description" {
  description = "ingress rule description"
}

variable "es_port" {
  description = "es port"
}

variable "s3_bucket" {
  description = "s3 bucket name"
}