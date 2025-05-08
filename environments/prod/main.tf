module "vpc" {
  source                = "../../modules/vpc"
  vpc_cidr              = var.vpc_cidr
  environment           = var.environment
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  create_nat_gateway_per_az = var.create_nat_gateway_per_az
}
