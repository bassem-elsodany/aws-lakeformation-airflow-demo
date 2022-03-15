################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"

  name                 = "${local.name}-vpc"
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.99.0.0/22", "10.99.4.0/22", "10.99.8.0/22"]
  database_subnets  = ["10.99.12.0/22", "10.99.16.0/22", "10.99.20.0/22"]
  private_subnets = ["10.99.24.0/22", "10.99.28.0/22", "10.99.32.0/22"]


  private_subnet_suffix = "mwaa"
  enable_nat_gateway   = true
  single_nat_gateway   = true
  
  enable_dns_hostnames = true
  enable_dns_support   = true

  create_database_subnet_group           = false
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  tags = local.tags

  private_subnet_tags = {
        Terraform = "true"
        Environment = "${local.environment}"
        Public="private"
  }

}

################################################################################
# VPC Endpoints 
################################################################################
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${local.region}.s3"

  tags = "${local.tags}"
}

resource "aws_vpc_endpoint_route_table_association" "db" {
  route_table_id  = module.vpc.database_route_table_ids.0
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}