# ======================================================
# VPC
# ======================================================
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.aws_region}-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.aws_region}-${var.environment}-igw"
  }
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.aws_region}-${var.environment}-route-table"
  }
}

resource "aws_default_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.aws_region}-${var.environment}-security-group"
  }
}

# ======================================================
# Private Subnets
# ======================================================
resource "aws_default_network_acl" "acl" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  subnet_ids             = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id, aws_subnet.private_subnet_az3.id]

  ingress {
    protocol   = -1
    rule_no    = 1000
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = "${var.aws_region}-${var.environment}-private-nacl"
  }
}

resource "aws_route_table" "private_route_table_az1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.aws_region}-${var.environment}-private-route-table-az1"
  }
}

resource "aws_route_table" "private_route_table_az2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.aws_region}-${var.environment}-private-route-table-az2"
  }
}

resource "aws_route_table" "private_route_table_az3" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.aws_region}-${var.environment}-private-route-table-az3"
  }
}

resource "aws_route" "private_route_nat_az1" {
  route_table_id         = aws_route_table.private_route_table_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nate_gateway_1.id
}

resource "aws_route" "private_route_nat_az2" {
  route_table_id         = aws_route_table.private_route_table_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nate_gateway_2.id
}

resource "aws_route" "private_route_nat_az3" {
  route_table_id         = aws_route_table.private_route_table_az3.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nate_gateway_3.id
}

resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_az1[0]
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.aws_region}-${var.environment}-private-subnet-az1"
    Tier = "Private"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_route_table_az1.id
}

resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_az2[0]
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.aws_region}-${var.environment}-private-subnet-az2"
    Tier = "Private"
  }
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_route_table_az2.id
}

resource "aws_subnet" "private_subnet_az3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_az3[0]
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "${var.aws_region}-${var.environment}-private-subnet-az3"
    Tier = "Private"
  }
}

resource "aws_route_table_association" "private_3" {
  subnet_id      = aws_subnet.private_subnet_az3.id
  route_table_id = aws_route_table.private_route_table_az3.id
}

# ======================================================
# Public Subnets
# ======================================================
resource "aws_network_acl" "nacl" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id, aws_subnet.public_subnet_az3.id]

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 30
    protocol   = "tcp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 40
    protocol   = "tcp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }
  tags = {
    Name = "${var.aws_region}-${var.environment}-public-nacl"
  }
}

resource "aws_subnet" "public_subnet_az1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_az1[0]
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.aws_region}-${var.environment}-public-subnet-az1"
    Tier = "Public"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_az2[0]
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.aws_region}-${var.environment}-public-subnet-az2"
    Tier = "Public"
  }
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_subnet" "public_subnet_az3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_az3[0]
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "${var.aws_region}-${var.environment}-public-subnet-az3"
    Tier = "Public"
  }
}

resource "aws_route_table_association" "public_3" {
  subnet_id      = aws_subnet.public_subnet_az3.id
  route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_eip" "nate_gateway_1_eip" {}

resource "aws_nat_gateway" "nate_gateway_1" {
  allocation_id = aws_eip.nate_gateway_1_eip.id
  subnet_id     = aws_subnet.public_subnet_az1.id
  tags = {
    Name = "${var.aws_region}-${var.environment}-nat-gateway-1"
  }
}

resource "aws_eip" "nate_gateway_2_eip" {}

resource "aws_nat_gateway" "nate_gateway_2" {
  allocation_id = aws_eip.nate_gateway_2_eip.id
  subnet_id     = aws_subnet.public_subnet_az2.id
  tags = {
    Name = "${var.aws_region}-${var.environment}-nat-gateway-2"
  }
}

resource "aws_eip" "nate_gateway_3_eip" {}

resource "aws_nat_gateway" "nate_gateway_3" {
  allocation_id = aws_eip.nate_gateway_3_eip.id
  subnet_id     = aws_subnet.public_subnet_az3.id
  tags = {
    Name = "${var.aws_region}-${var.environment}-nat-gateway-3"
  }
}

# ======================================================
# CloudWatch Logs
# ======================================================
resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name              = "/vpc/flowlogs/${aws_vpc.vpc.id}"
  retention_in_days = 7
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name               = "role-${aws_vpc.vpc.id}-vpc-logs"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_trust.json
  path               = "/iac/vpc/"
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name   = "policy-${aws_vpc.vpc.id}-vpc-logs"
  role   = aws_iam_role.vpc_flow_logs_role.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_policy.json
}

resource "aws_flow_log" "vpc_flow_log_cloudwatch" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
  iam_role_arn         = aws_iam_role.vpc_flow_logs_role.arn
  tags = {
    Name = "${var.aws_region}-${var.environment}-vpc-flow-log"
  }
}

# ======================================================
# VPC Endpoints
# ======================================================
resource "aws_vpc_endpoint" "public_s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [
    aws_vpc.vpc.default_route_table_id
  ]
  tags = {
    Name = "${var.aws_region}-${var.environment}-public-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "private_s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [
    aws_route_table.private_route_table_az1.id,
    aws_route_table.private_route_table_az2.id,
    aws_route_table.private_route_table_az3.id
  ]
  tags = {
    Name = "${var.aws_region}-${var.environment}-private-s3-endpoint"
  }
}

# Interface endpoints for services used by ECS/Fargate tasks to pull images and secrets
resource "aws_security_group" "vpc_endpoints_sg" {
  name        = "${var.aws_region}-${var.environment}-vpce-sg"
  description = "Security group for VPC Interface endpoints"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_region}-${var.environment}-vpce-sg"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id, aws_subnet.private_subnet_az3.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.aws_region}-${var.environment}-ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id, aws_subnet.private_subnet_az3.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.aws_region}-${var.environment}-ecr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id, aws_subnet.private_subnet_az3.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.aws_region}-${var.environment}-sts-endpoint"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id, aws_subnet.private_subnet_az3.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.aws_region}-${var.environment}-secretsmanager-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id, aws_subnet.private_subnet_az3.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.aws_region}-${var.environment}-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id, aws_subnet.private_subnet_az3.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.aws_region}-${var.environment}-ssmmessages-endpoint"
  }
}
