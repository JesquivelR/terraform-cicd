vpc_cidr               = "10.1.0.0/16"
environment            = "prod"
public_subnet_cidrs    = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs   = ["10.1.101.0/24", "10.1.102.0/24"]
create_nat_gateway_per_az = true
