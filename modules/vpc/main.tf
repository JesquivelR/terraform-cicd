# Obtiene dinámicamente las zonas de disponibilidad de la región
data "aws_availability_zones" "available" {}

# VPC con protección contra destrucción accidental
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Subredes públicas: asigna IP pública por defecto
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${each.key + 1}"
  }
}

# Subredes privadas
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[each.key]

  tags = {
    Name = "${var.environment}-private-subnet-${each.key + 1}"
  }
}

#########################
# GATEWAY Y TABLAS DE RUTAS
#########################

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# Tabla de rutas pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# Asociación de subredes públicas con la tabla de rutas
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

####################################
# NAT GATEWAY Y TABLAS DE RUTAS PRIVADAS
####################################

# NAT Gateway(s): Se crea uno único o uno por AZ según la variable
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway_per_az ? length(aws_subnet.public) : 1
  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip${var.create_nat_gateway_per_az ? "-${count.index + 1}" : ""}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.create_nat_gateway_per_az ? length(aws_subnet.public) : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.create_nat_gateway_per_az ? aws_subnet.public[count.index].id : aws_subnet.public[0].id

  tags = {
    Name = "${var.environment}-nat-gw${var.create_nat_gateway_per_az ? "-${count.index + 1}" : ""}"
  }
}

# Tabla de rutas privada(s)
resource "aws_route_table" "private" {
  count  = var.create_nat_gateway_per_az ? length(aws_subnet.private) : 1
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.create_nat_gateway_per_az ? aws_nat_gateway.nat[count.index].id : aws_nat_gateway.nat[0].id
  }

  tags = {
    Name = "${var.environment}-private-rt${var.create_nat_gateway_per_az ? "-${count.index + 1}" : ""}"
  }

}

# Asociación de subredes privadas con la tabla de rutas privada
resource "aws_route_table_association" "private" {
  for_each       = { for idx, subnet in aws_subnet.private : idx => subnet }
  subnet_id      = each.value.id
  route_table_id = var.create_nat_gateway_per_az ? aws_route_table.private[each.key].id : aws_route_table.private[0].id
}
