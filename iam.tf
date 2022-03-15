data "aws_iam_policy_document" "buckets_policy" {
    statement {
      actions = ["s3:GetObject","s3:PutObject","s3:DeleteObject"]
      resources = [for k in local.s3_buckets : "arn:aws:s3:::${k}"]
  }
    statement {
      actions = ["s3:GetObject","s3:PutObject","s3:DeleteObject"]
      resources = [for k in local.s3_buckets : "arn:aws:s3:::${k}/*"]
  }
}


################################################################################
# IAM User
################################################################################

# LakeFormation Admin User
module "iam_user_admin_lakeformation" {
  source = "terraform-aws-modules/iam/aws//modules/iam-user"

  name = "${local.name}-admin-user"

  create_iam_user_login_profile = true
  create_iam_access_key         = true
  password_reset_required       = false
}

# LakeFormation Analyst User
module "iam_user_analyst_lakeformation" {
  source = "terraform-aws-modules/iam/aws//modules/iam-user"

  name = "${local.name}-analyst-user"

  create_iam_user_login_profile = true
  create_iam_access_key         = true
  password_reset_required       = false
}

################################################################################
# IAM Group
################################################################################

# LakeFormation Admin Group
module "iam_group_lakeformation_admin" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"

  name = "${local.name}-admin-group"

  group_users = [
    module.iam_user_admin_lakeformation.iam_user_name,
  ]

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin",
  ]
}

# LakeFormation Analyst Group
module "iam_group_lakeformation_analyst" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"

  name = "${local.name}-analyst-group"

  group_users = [
    module.iam_user_analyst_lakeformation.iam_user_name,
  ]

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonAthenaFullAccess",
  ]
    custom_group_policies = [
    {
      name   = "AllowS3ForAthenaQuery"
      policy = data.aws_iam_policy_document.athena_query.json
    },    
    {
      name   = "AllowS3Read"
      policy = data.aws_iam_policy_document.athena_data.json
    }
  ]
}

################################################################################
# IAM Policy
################################################################################
# Athena Queries
data "aws_iam_policy_document" "athena_query" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
    "arn:aws:s3:::${local.s3_athena_query_bucket}",
    "arn:aws:s3:::${local.s3_athena_query_bucket}/*"
     ]
  }
}

data "aws_iam_policy_document" "athena_data" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]

    resources = [
    "arn:aws:s3:::${local.s3_buckets[1]}/*",
    "arn:aws:s3:::${local.s3_buckets[2]}/*"
     ]
  }
}

module "iam_policy_lakeformation" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4"

  name        = "${local.name}-policy"
  path        = "/"
  description = "${local.name}-policy"

  policy = data.aws_iam_policy_document.buckets_policy.json
}

# Glue Policy
resource "aws_iam_policy" "glue_policy" {
  name        = "datalake_user_basic"
  path        = "/"
  description = "Policy for AWS Glue service role which allows access to related services including EC2, S3, and Cloudwatch Logs"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lakeformation:GetDataAccess",
                "glue:GetTable",
                "glue:GetTables",
                "glue:StartWorkflowRun",
                "glue:SearchTables",
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:GetPartitions",
                "lakeformation:GetResourceLFTags",
                "lakeformation:ListLFTags",
                "lakeformation:GetLFTag",
                "lakeformation:SearchTablesByLFTags",
                "lakeformation:SearchDatabasesByLFTags",
                "lakeformation:GetWorkUnits",
                "lakeformation:StartQueryPlanning",
                "lakeformation:GetWorkUnitResults",
                "lakeformation:GetQueryState",
                "lakeformation:GetQueryStatistics"
           ],
            "Resource": "*"
        }
    ]
}
EOF
}

# MWAA Secret Manager Access
resource "aws_iam_policy" "secrets_manager_read_write" {
  name        = "secrets_manager_read_write"
  path        = "/"
  description = "SecretsManagerReadWrite"

  policy = jsonencode(
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": "arn:aws:secretsmanager:${local.region}:${data.aws_caller_identity.current.account_id}:secret:*",
        },
        {
            "Effect": "Allow",
            "Action": "secretsmanager:ListSecrets",
            "Resource": "*"
        }
    ]
})
}
################################################################################
# IAM Role Attachement
################################################################################
# Glue Attachements
resource "aws_iam_group_policy_attachment" "glue_attach" {
  group       = module.iam_group_lakeformation_analyst.group_name
  policy_arn = aws_iam_policy.glue_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_secret_manager_attach" {
  role       = module.iam_assumable_role_lakeformation.iam_role_name
  policy_arn = aws_iam_policy.secrets_manager_read_write.arn
}

# MWAA Secret manager Attachement
resource "aws_iam_role_policy_attachment" "mwaa_secret_manager_policy" {
  policy_arn = aws_iam_policy.secrets_manager_read_write.arn
  role       = aws_iam_role.mwaa_role.name
}

resource "aws_iam_role_policy_attachment" "mwaa_glue_policy" {
  policy_arn = aws_iam_policy.glue_policy.arn
  role       = aws_iam_role.mwaa_role.name
}

################################################################################
# IAM Role
################################################################################

module "iam_assumable_role_lakeformation" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4"

  #trusted_role_arns = [
   # module.iam_user_admin_lakeformation.iam_user_arn,
  #]

  trusted_role_services = [
    "glue.amazonaws.com"
  ]

  create_role = true
  role_name         = "${local.name}-role"
  role_requires_mfa = false
  attach_admin_policy = true

  tags = {
    Role = "Admin"
  }

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
     module.iam_policy_lakeformation.arn,
  ]
}

#Role for MWAA
resource "aws_iam_role" "mwaa_role" {
  name                  = "${local.name}-mwaa-role"
  force_detach_policies = true

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "airflow.amazonaws.com",
          "airflow-env.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  dynamic "inline_policy" {
    for_each = true == true ? [true] : []
    content {
      name = "mwaa_policy"
      policy = jsonencode(
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "airflow:PublishMetrics",
            "Resource": "arn:aws:airflow:${local.region}:${data.aws_caller_identity.current.account_id}:environment/${local.mwaa_environment_name}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject*",
                "s3:GetBucket*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${local.s3_mwaa_bucket}",
                "arn:aws:s3:::${local.s3_mwaa_bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:GetLogRecord",
                "logs:GetLogGroupFields",
                "logs:GetQueryResults"
            ],
            "Resource": [
                "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${local.mwaa_environment_name}-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:PutMetricData",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sqs:ChangeMessageVisibility",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "sqs:GetQueueUrl",
                "sqs:ReceiveMessage",
                "sqs:SendMessage"
            ],
            "Resource": "arn:aws:sqs:${local.region}:*:airflow-celery-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:DescribeKey",
                "kms:GenerateDataKey*",
                "kms:Encrypt"
            ],
            "NotResource": "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*",
            "Condition": {
                "StringLike": {
                    "kms:ViaService": [
                        "sqs.${local.region}.amazonaws.com"
                    ]
                }
            }
        }
    ]
})
    }
  }
}