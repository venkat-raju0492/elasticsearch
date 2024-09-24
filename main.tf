terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  elasticsearch_domain_name = "${var.project}-es-domain-${var.env}"
  cloudwatch_prefix         = "/es/${var.project}"
  cloudwatch_logs_group     = var.cloudwatch_logs_group == "" ? "${local.cloudwatch_prefix}-elasticsearch-${var.env}" : var.cloudwatch_logs_group
  account_id                = data.aws_caller_identity.current.account_id

  # Common tags to be assigned to all resources
  common_tags = {
    Project     = var.project
    Environment = var.env
    CreatedBy   = "Terraform"
    CostCategory = var.costcategory
   }  
}

resource "random_password" "admin_key" {
  length           = 16
  special          = true
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "es_admin_password" {
  name        = "${var.project}-es-admin-password-${var.env}"   
  description = "The ES admin password"
}

resource "aws_secretsmanager_secret_version" "es_admin_password" {
  secret_id     = aws_secretsmanager_secret.es_admin_password.id
  secret_string = random_password.admin_key.result
}

resource "aws_elasticsearch_domain" "es-domain" {
  domain_name            = local.elasticsearch_domain_name
  elasticsearch_version   = var.elasticsearch_version

  cluster_config {
    instance_count           = var.instance_count
    instance_type            = var.instance_type
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type    = var.dedicated_master_type
    dedicated_master_count   = var.dedicated_master_count
    zone_awareness_enabled   = var.dedicated_master_count > 1 ? true : false
    dynamic "zone_awareness_config" {
      for_each = var.dedicated_master_count > 1 ? [var.dedicated_master_count] : []
      content {
        availability_zone_count = var.instance_count
      }
    }
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_type = var.ebs_options_volume_type
    volume_size = var.ebs_options_volume_size
    iops        = var.ebs_options_iops
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.sg-es.id]
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  node_to_node_encryption {
    enabled = true
  }

  advanced_security_options{
    enabled = true
    internal_user_database_enabled = true

  master_user_options {
    master_user_name    = var.es_uname
    master_user_password = random_password.admin_key.result
  }

  }
  encrypt_at_rest{
    enabled = true
  }

  domain_endpoint_options{
    enforce_https = true
    tls_security_policy = var.tls_security_policy
  }

access_policies = (var.leader_cluster == true ? 
  
  <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:ESHttp*"
      ],
      "Resource": "arn:aws:es:${var.region}:${local.account_id}:domain/${local.elasticsearch_domain_name}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:ESCrossClusterGet",
      "Resource": "arn:aws:es:${var.region}:${local.account_id}:domain/${local.elasticsearch_domain_name}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::${local.account_id}:role/${var.iam_role_name}"
    }
  ]
}
POLICY
 : 
  <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
      "es:*",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream"
      ],  
      "Principal": "*",
      "Effect": "Allow",
      "Resource": "arn:aws:es:${var.region}:${local.account_id}:domain/${local.elasticsearch_domain_name}/*"
    }
  ]
}
POLICY
  )

  log_publishing_options {
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_domain_logs_group.arn
      log_type                 = "INDEX_SLOW_LOGS"
    }

  tags = merge(local.common_tags, tomap({
    "Name" = "${var.project}-es-domain-${var.env}"
  }))

}


resource "aws_cloudwatch_log_group" "es_domain_logs_group" {
  name              = local.cloudwatch_logs_group
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_resource_policy" "es_domain_logs_group_policy" {
  policy_name = "example"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}
