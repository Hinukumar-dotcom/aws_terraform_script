####################### VPC_CREATION STARTS ############################################

resource "aws_vpc" "vpc_test" {
  cidr_block           = var.cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name  = var.vpc_name
    Env   = "test"
    owner = "Hinukumar"
  }
}


############################### CRAETING INTERNET GATEWAY ##############################

resource "aws_internet_gateway" "IGW_Suresbyvpc_test" {
  vpc_id = aws_vpc.vpc_test.id

  tags = {
    Name = "IGW_Suresbyvpc_test"
    Env = "test"
  }
}

############################# CREATING SUBNETS IN AVAILABILITY ZONES ###################


resource "aws_subnet" "public_subnet" { 
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = "${var.cidr_block_subnet_1}"
  availability_zone       = var.Availablity_Zone_1
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public_subnet_1-${var.vpc_name}"
    Env  = "test"
  }
}

resource "aws_subnet" "private_subnet" { 
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = "${var.cidr_block_subnet_2}"
  availability_zone       = var.Availablity_Zone_2
  map_public_ip_on_launch = "false"

  tags = {
    Name = "private_subnet-2-${var.vpc_name}"
    Env  = "test"
  }
}

resource "aws_subnet" "DB_subnet" { 
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = "${var.cidr_block_subnet_3}"
  availability_zone       = var.Availablity_Zone_3
  map_public_ip_on_launch = "false"

  tags = {
    Name = "DB_Subnet-${var.vpc_name}"
    Env  = "test"
  }
}

#################################### CREATING SECURITY GROUPS ####################################

resource "aws_security_group" "public_subnet" {
  vpc_id      = aws_vpc.vpc_test.id
  name        = "public_Subnet_sg"
  description = "Nat Instances Security Group"
}

resource "aws_security_group_rule" "public-to-private-ssh-egress" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = "${aws_security_group.public_subnet.id}"
    source_security_group_id = "${aws_security_group.private_subnet.id}"
}

resource "aws_security_group_rule" "SSH-open-to-public" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = "${aws_security_group.public_subnet.id}"
    cidr_blocks = ["0.0.0.0/0"]
    #source_security_group_id = "${aws_security_group.private_subnet.id}"
}



resource "aws_security_group" "private_subnet" {
  vpc_id      = aws_vpc.vpc_test.id
  name        = "private_subnet_sg"
  description = "private Instances Security Group"
}

resource "aws_security_group_rule" "SSH-open-from-public-to-private" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = "${aws_security_group.private_subnet.id}"
    #cidr_blocks = ["0.0.0.0/0"]
    source_security_group_id = "${aws_security_group.public_subnet.id}"
}


################################### ROUTING TABLE CREATION START ##################################

resource "aws_route_table" "RT-Internetout_IGW" {
  vpc_id = aws_vpc.vpc_test.id

  route {
    cidr_block = "${var.cidr_block_outside}"
    gateway_id = "${aws_internet_gateway.IGW_Suresbyvpc_test.id}"
  }

  tags = {
    Name = "public-route-table-${var.vpc_name}"
    Env = "test"
  }
}

resource "aws_route_table" "RT-public_subnet" {
  vpc_id = aws_vpc.vpc_test.id

  tags = {
    Name = "public-route-table-${var.vpc_name}"
    Env = "test"
  }
}

################################### SUBNET ASSOCIATIONS TO ROUTE TABLE ############################

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.RT-Internetout_IGW.id}"
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.RT-public_subnet.id}"
}

resource "aws_route_table_association" "DB_subnet_association" {
  subnet_id = "${aws_subnet.DB_subnet.id}"
  route_table_id = "${aws_route_table.RT-public_subnet.id}"
}





/*
############################## Outgoing ports ######################################################

egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cidr_block_outside
    description = "Allow HTTP Traffic to World"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cidr_block_outside
    description = "Allow HTTPS Traffic to World"
  }

  egress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = var.cidr_block_outside
    description = "Allow ICMP Traffic to World"
  }

egress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = "${aws_security_group.private_subnet.id}"
    description     = "Allow SSH Traffic to private_Subnet"
  }

  egress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"
    security_groups = "${aws_security_group.private_subnet.id}"
    description     = "Allow RDP Traffic to private_Subnet"
  }

  tags = {
    Name = "public_subnet-${var.vpc_name}"
    Env  = "test"
  }
}


################################## SG CREATION FOR PRIVATE SUBNET ###########################################

resource "aws_security_group" "private_subnet" {
  vpc_id      = aws_vpc.vpc_test.id
  name        = "private_subnet_sg"
  description = "private Instances Security Group"

ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    security_groups = "${aws_security_group.public_subnet.id}"
    description = "Allow RDP Traffic from public Subnets"
  }

ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = "${aws_security_group.public_subnet.id}"
    description = "Allow HTTP Traffic from public Subnets"
  }

ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = "${aws_security_group.public_subnet.id}"
    description = "Allow HTTPS Traffic from Public Subnets"
  }

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = "${aws_security_group.public_subnet.id}"
    description = "Allow SSH Traffic from Public Subnets"
  }

##################################### OUTGOING PORTS #########################################

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cidr_Block_Outside
    description = "Allow HTTP Traffic to World"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cidr_block_outside
    description = "Allow HTTPS Traffic to World"
  }

egress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = "${aws_security_group.public_subnet.id}"
    description     = "Allow SSH Traffic to public_Subnet"
  }
}

*/

















