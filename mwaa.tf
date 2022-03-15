################################################################################
#MWAA security group.
################################################################################
resource "aws_security_group" "mwaa_security_group" {
  name        = "mwaa_security_group"
  description = "Security group for MWAA"
  vpc_id      = module.vpc.vpc_id


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = local.tags
}

################################################################################
# Creates a MWAA Environment resource.
################################################################################
resource "aws_mwaa_environment" "mwaa_instance" {
  
  airflow_configuration_options = {
    "core.default_task_retries" = 16
    "core.parallelism"          = 1
  }
  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "ERROR"
    }

    worker_logs {
      enabled   = true
      log_level = "CRITICAL"
    }
  }

  dag_s3_path        = local.s3_mwaa_bucket_structure[0]
  execution_role_arn = aws_iam_role.mwaa_role.arn
  name               = local.mwaa_environment_name
  webserver_access_mode = "PUBLIC_ONLY"

  network_configuration {
    security_group_ids = [aws_security_group.mwaa_security_group.id]
    subnet_ids         = [module.vpc.private_subnets[0],module.vpc.private_subnets[1]]
  }

  source_bucket_arn = aws_s3_bucket.s3_mwaa_bucket.arn
}
