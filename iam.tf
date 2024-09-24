## es s3 snapshot role

resource "aws_iam_policy" "es-task-policy" {
  name = "${var.project}-es-policy-${var.env}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "es:*",
            "Resource": [
                "arn:aws:es:${var.region}:${local.account_id}:domain/${local.elasticsearch_domain_name}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::${local.account_id}:role/${var.project}-es-role-${var.env}"
        }
    ]
}
EOF
}

resource "aws_iam_role" "es-task-role" {
  name = "${var.project}-es-role-${var.env}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "es.amazonaws.com",
                    "opensearchservice.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  tags = merge(local.common_tags, tomap({
    Name = "${var.project}-es-role-${var.env}"
  }))
}

resource "aws_iam_role_policy_attachment" "es-policy-attachement" {
  role       = aws_iam_role.es-task-role.name
  policy_arn = aws_iam_policy.es-task-policy.arn
}
