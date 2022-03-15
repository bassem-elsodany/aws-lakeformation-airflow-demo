################################################################################
# S3 Buckets
################################################################################
resource "aws_s3_bucket" "datalake_s3_buckets" {
  count = "${length(local.s3_buckets)}"
  bucket = "${local.s3_buckets[count.index]}"
  force_destroy = true
  tags = local.tags
}

# S3 Athena Query Bucket
resource "aws_s3_bucket" "datalake_s3_athena_bucket" {
  bucket = "${local.s3_athena_query_bucket}"
  force_destroy = true
  tags = local.tags
}

# S3 Glue Jobs Bucket
resource "aws_s3_bucket" "datalake_s3_glue_jobs_bucket" {
  bucket = "${local.s3_glue_jobs_bucket}"
  force_destroy = true
  tags = local.tags
}

# S3 MWAA Bucket
resource "aws_s3_bucket" "s3_mwaa_bucket" {
  bucket = "${local.s3_mwaa_bucket}"
  force_destroy = true
  tags = local.tags
}

# DataLake S3 ACL
resource "aws_s3_bucket_public_access_block" "datalake_s3_buckets_public_access_block" {
  count = "${length(local.s3_buckets)}"
  bucket = aws_s3_bucket.datalake_s3_buckets[count.index].id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets  = true
  ignore_public_acls = true
}

# Athena Query S3 ACL
resource "aws_s3_bucket_public_access_block" "datalake_s3_athena_buckets_public_access_block" {
  bucket = aws_s3_bucket.datalake_s3_athena_bucket.id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets  = true
  ignore_public_acls = true
}

# Glue Jobs S3 ACL
resource "aws_s3_bucket_public_access_block" "datalake_s3_glue_jobs_buckets_public_access_block" {
  bucket = aws_s3_bucket.datalake_s3_glue_jobs_bucket.id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets  = true
  ignore_public_acls = true
}

# MWAA S3 ACL
resource "aws_s3_bucket_public_access_block" "s3_mwaa_buckets_public_access_block" {
  bucket = aws_s3_bucket.s3_mwaa_bucket.id
  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets  = true
  ignore_public_acls = true
}


# DataLake S3 Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "datalake_s3_buckets_sse" {
  count = "${length(local.s3_buckets)}"
  bucket = aws_s3_bucket.datalake_s3_buckets[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# Athena Query S3 Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "datalake_s3_athena_buckets_sse" {
  bucket = aws_s3_bucket.datalake_s3_athena_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# Glue Jobs S3 Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "datalake_s3_glue_jobs_buckets_sse" {
  bucket = aws_s3_bucket.datalake_s3_glue_jobs_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# MWAA dags S3 Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_mwaa_buckets_sse" {
  bucket = aws_s3_bucket.s3_mwaa_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# DataLake S3 Versioning
resource "aws_s3_bucket_versioning" "datalake_s3_buckets_versioning" {
  count = "${length(local.s3_buckets)}"
  bucket = aws_s3_bucket.datalake_s3_buckets[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Athena Query S3 Versioning
resource "aws_s3_bucket_versioning" "datalake_s3_athena_buckets_versioning" {
  bucket = aws_s3_bucket.datalake_s3_athena_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Glue Jobs S3 Versioning
resource "aws_s3_bucket_versioning" "datalake_s3_glue_jobs_buckets_versioning" {
  bucket = aws_s3_bucket.datalake_s3_glue_jobs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# MWAA Dags S3 Versioning
resource "aws_s3_bucket_versioning" "s3_mwaa_buckets_versioning" {
  bucket = aws_s3_bucket.s3_mwaa_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DataLake S3 RAW Objects
resource "aws_s3_object" "raw_objects" {
    count = "${length(local.s3_buckets_raw_structure)}"
    bucket = aws_s3_bucket.datalake_s3_buckets.0.id
    key    = "${local.s3_buckets_raw_structure[count.index]}/"
}


# DataLake S3 Processed Objects
resource "aws_s3_object" "processed_objects" {
    count = "${length(local.s3_buckets_processed_structure)}"
    bucket = aws_s3_bucket.datalake_s3_buckets.1.id
    key    = "${local.s3_buckets_processed_structure[count.index]}/"
}


# DataLake S3 Curated Objects
resource "aws_s3_object" "curated_objects" {
    count = "${length(local.s3_buckets_curated_structure)}"
    bucket = aws_s3_bucket.datalake_s3_buckets.2.id
    key    = "${local.s3_buckets_curated_structure[count.index]}/"
}

# S3 MWAA Objects
resource "aws_s3_object" "mwaa_objects" {
    count = "${length(local.s3_mwaa_bucket_structure)}"
    bucket = aws_s3_bucket.s3_mwaa_bucket.id
    key    = "${local.s3_mwaa_bucket_structure[count.index]}/"
}

# S3 DAGS Objects
resource "aws_s3_object" "dags_objects" {
  for_each = fileset("dags/", "*")

  bucket = aws_s3_bucket.s3_mwaa_bucket.id
  key    = "dags/${each.value}"
  acl    = "private"
  source = "dags/${each.value}"
  etag   = filemd5("dags/${each.value}")
}


# S3 Glue Jobs Objects
resource "aws_s3_object" "glue_jobs_objects" {
  for_each = fileset("jobs/", "*")

  bucket = aws_s3_bucket.datalake_s3_glue_jobs_bucket.id
  key    = "${each.value}"
  acl    = "private"
  source = "jobs/${each.value}"
  etag   = filemd5("jobs/${each.value}")
}