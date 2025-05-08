vpc_cidr               = "10.0.0.0/16"
environment            = "dev"
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24"]
create_nat_gateway_per_az = false

# Variables para EC2
instance_type    = "t2.micro"
desired_capacity = 1
max_size         = 1
min_size         = 1