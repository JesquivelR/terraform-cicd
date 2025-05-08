variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "create_nat_gateway_per_az" {
  description = "Flag to create a NAT Gateway per AZ (set to false for dev)"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum capacity for ASG"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum capacity for ASG"
  type        = number
  default     = 1
}