resource "aws_security_group" "sg-es" {
  name        = "${var.project}-es-domain-${var.env}"
  description = "${var.project}-es-domain-${var.env}"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.es_port
    to_port         = var.es_port
    protocol        = "tcp"
    security_groups = var.allow_security_group_ids
    cidr_blocks     = var.allowed_cidrs
    description     = var.ingress_rule_description
  }

  tags = merge(local.common_tags, tomap({
    Name = "${var.project}-es-domain-${var.env}"
  }))
}

