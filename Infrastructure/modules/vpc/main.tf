data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    name = var.vpc_name
  })
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)   #this defines how many public subnets to create based on the length of the input variable
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet[count.index]
  availability_zone       = var.availability_zones[count.index] # Distribute across AZs
  
  # Automatically assign public IPs to resources launched here
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                        = "public-subnet-1"
    "kubernetes.io/role/elb"                    = "1" # Indicates this subnet can host ELB resources
    "kubernetes.io/cluster/${var.cluster_name}" = "${var.cluster_name}"  # Indicates this subnet is part of the Kubernetes cluster
  })
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet)   #this defines how many private subnets to create based on the length of the input variable
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet[count.index]
  availability_zone       = var.availability_zones[count.index] # Distribute across AZs
  map_public_ip_on_launch = false # Forces instances to only get private IPs

  tags = merge(var.tags, {
    Name                                              = "private-subnet-1"
    "kubernetes.io/role/internal-elb"                 = "1" # Indicates this subnet can host internal ELB resources
    "kubernetes.io/cluster/${var.cluster_name}"       = "${var.cluster_name}"  # Indicates this subnet is part of the Kubernetes cluster
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "main-igw"
  })
  depends_on = [ aws_vpc.main ]
}


resource "aws_nat_gateway" "aws_nat_gateway" {
  count        = var.single_nat_gateway ? 1 : length(var.public_subnet) # Create one NAT Gateway if single_nat_gateway is true, otherwise one per public subnet
  allocation_id = aws_eip.nat_eip[count.index].id # Use the first EIP for the NAT Gateway (if single_nat_gateway is true)
  subnet_id     = var.single_nat_gateway ? aws_subnet.public_subnet[0].id : aws_subnet.public_subnet[count.index].id

  tags = merge(var.tags, {
    Name = "main-nat-gateway"
  })
  depends_on = [ aws_internet_gateway.igw ]
}

# 3. Create a Route Table for Private Subnets
resource "aws_route_table" "private_rt" {
  count  = var.single_nat_gateway ? 1 : length(var.private_subnet)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.aws_nat_gateway[0].id : aws_nat_gateway.aws_nat_gateway[count.index].id # Route through the NAT Gateway (if single_nat_gateway is true, use the first one)
  }

  tags = merge(var.tags,  {
    Name = "private-route-table"
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "public-route-table"
  })
}


resource "aws_eip" "nat_eip" {
  count  = var.single_nat_gateway ? 1 : length(var.public_subnet) # Create an EIP for each NAT Gateway (if multiple)
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]

  tags = merge(var.tags, {
    Name = "nat-eip-${count.index}"
  })
}


resource "aws_route_table_association" "public" {
  count = length(var.public_subnet)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "private" {
  count = length(var.private_subnet)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private_rt[0].id: aws_route_table.private_rt[count.index].id
}


