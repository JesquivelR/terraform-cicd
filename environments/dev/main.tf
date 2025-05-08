module "vpc" {
  source                = "../../modules/vpc"
  vpc_cidr              = var.vpc_cidr
  environment           = var.environment
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  create_nat_gateway_per_az = var.create_nat_gateway_per_az
}

module "ec2" {
  source             = "../../modules/ec2"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  environment        = var.environment
  instance_type      = var.instance_type
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
}