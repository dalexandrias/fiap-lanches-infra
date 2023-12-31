data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "fiap_lanches_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Public subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.fiap_lanches_vpc.id
  count                   = 1
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-${data.aws_availability_zones.available.names[0]}-public-subnet-1"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.fiap_lanches_vpc.id
  count                   = 1
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-${data.aws_availability_zones.available.names[1]}-public-subnet-2"
    Environment = "${var.environment}"
  }
}


# Private Subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.fiap_lanches_vpc.id
  count                   = 1
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 3)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.app_name}-${data.aws_availability_zones.available.names[0]}-private-subnet-1"
    Environment = "${var.environment}"
  }
}


resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.fiap_lanches_vpc.id
  count                   = 1
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 4)
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.app_name}-${data.aws_availability_zones.available.names[1]}-private-subnet-2"
    Environment = "${var.environment}"
  }
}

# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.fiap_lanches_vpc.id

  tags = {
    Name        = "${var.app_name}-private-route-table"
    Environment = "${var.environment}"
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.fiap_lanches_vpc.id

  tags = {
    Name        = "${var.app_name}-public-route-table"
    Environment = "${var.environment}"
  }
}

# Route table associations for both Public Subnets
resource "aws_route_table_association" "public_1" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnet_1[count.index].id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "public_2" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnet_2[count.index].id
  route_table_id = aws_route_table.rt_public.id
}

# Route table associations for both Private Subnets
resource "aws_route_table_association" "private_1" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.private_subnet_1[count.index].id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "private_2" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.private_subnet_2[count.index].id
  route_table_id = aws_route_table.rt_private.id
}

# Subnets
# Internet Gateway para subnet publica, libera o acesso via internet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.fiap_lanches_vpc.id
  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.environment
  }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.ig]
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.rt_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# # Default Security Group of VPC
# resource "aws_security_group" "default" {
#   name        = "${var.environment}-default-sg"
#   description = "Default SG to alllow traffic from the VPC"
#   vpc_id      = aws_vpc.vpc.id
#   depends_on = [
#     aws_vpc.vpc
#   ]

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Environment = "${var.environment}"
#   }
# }
