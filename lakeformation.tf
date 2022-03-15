################################################################################
# LakeFormation Security
################################################################################
resource "aws_lakeformation_data_lake_settings" "admin" {
  admins = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole",module.iam_user_admin_lakeformation.iam_user_arn,]
}

################################################################################
# LAKE DATABASE
################################################################################
resource "aws_glue_catalog_database" "lakeformation_database" {
  depends_on  = [aws_s3_bucket.datalake_s3_buckets]
  count = "${length(local.s3_buckets)}"
  location_uri = "s3://${local.s3_buckets[count.index]}"
  name         = "${local.lakeformation_databases[count.index]}"
}

################################################################################
# LAKE DATABASE PERMISSIONS
################################################################################
resource "aws_lakeformation_permissions" "lakeformation_database_permission" {
  count = "${length(aws_glue_catalog_database.lakeformation_database)}"
  principal = module.iam_assumable_role_lakeformation.iam_role_arn
  permissions                   = ["ALL", "ALTER", "CREATE_TABLE", "DESCRIBE", "DROP"]
  permissions_with_grant_option = ["ALL", "ALTER", "CREATE_TABLE", "DESCRIBE", "DROP"]

  database {
    name       = "${aws_glue_catalog_database.lakeformation_database[count.index].name}"
  }
}