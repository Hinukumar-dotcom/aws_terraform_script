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

######################## DB_Subnet Group Creation ###########################################

resource "aws_subnet" "DB_subnet1" { 
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = "${var.cidr_block_subnet_3}"
  availability_zone       = var.Availablity_Zone_3
  map_public_ip_on_launch = "true"

  tags = {
    Name = "DB_Subnet1-${var.vpc_name}"
    Env  = "test"
  }
}


resource "aws_subnet" "DB_subnet2" { 
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = "${var.cidr_block_subnet_4}"
  availability_zone       = var.Availablity_Zone_4
  map_public_ip_on_launch = "true"

  tags = {
    Name = "DB_Subnet2-${var.vpc_name}"
    Env  = "test"
  }
}

 resource "aws_db_subnet_group" "mssqldatabase" {
   name = "mysqldbsubnetgrp"
   description = "Database subnet groups for Suresby_vpc"
   
   subnet_ids = ["${aws_subnet.DB_subnet1.id}", "${aws_subnet.DB_subnet2.id}"]
   
   tags = {

     name = "Database_subnet_group"
     Env = "test"
     owner = "Hinukumar"
   }
 }

############################## DATABASE CREATION END ############################################


#################################### DATA BASE INSTANCE CREATION ###############################


# Create a database server

resource "aws_db_instance" "suresby_demo_db" {
  engine         = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name           = "suresby_db"
  username       = "rootuser"
  password       = "rootpassword"
  allocated_storage    = 20
  storage_type         = "gp2"
  publicly_accessible = "true"

  vpc_security_group_ids = ["${aws_security_group.db_subnet1_sg.id}","${aws_security_group.db_subnet2_sg.id}"]

  skip_final_snapshot = "true"

  db_subnet_group_name = "mysqldbsubnetgrp"

   availability_zone = "us-east-1c"

   #parameter_group_name = "suresby_demo_db.mysql5.7"


}



#################################### CREATING SECURITY GROUPS ####################################

resource "aws_security_group" "public_subnet" {
  vpc_id      = aws_vpc.vpc_test.id
  name        = "public_Subnet_sg"
  description = "Nat Instances Security Group"
}

/*resource "aws_security_group_rule" "private-to-public-icmp-ingress" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "icmp"
    security_group_id = "${aws_security_group.public_subnet.id}"
    source_security_group_id = "${aws_security_group.private_subnet.id}"
}*/

resource "aws_security_group_rule" "public-to-private-ssh-egress" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = "${aws_security_group.public_subnet.id}"
    source_security_group_id = "${aws_security_group.private_subnet.id}"
}

/*resource "aws_security_group_rule" "public-to-private-icmp-egress" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "icmp"
    security_group_id = "${aws_security_group.public_subnet.id}"
    source_security_group_id = "${aws_security_group.private_subnet.id}"
}*/


resource "aws_security_group_rule" "SSH-open-to-public" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = "${aws_security_group.public_subnet.id}"
    cidr_blocks = ["0.0.0.0/0"]
    #source_security_group_id = "${aws_security_group.private_subnet.id}"
}

resource "aws_security_group_rule" "HTTP-open-to-public" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = "${aws_security_group.public_subnet.id}"
    cidr_blocks = ["0.0.0.0/0"]
    #source_security_group_id = "${aws_security_group.private_subnet.id}"
}

resource "aws_security_group_rule" "HTTPS-open-to-public" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = "${aws_security_group.public_subnet.id}"
    cidr_blocks = ["0.0.0.0/0"]
    #source_security_group_id = "${aws_security_group.private_subnet.id}"
}

resource "aws_security_group_rule" "HTTP-outopen-to-public" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = "${aws_security_group.public_subnet.id}"
    cidr_blocks = ["0.0.0.0/0"]
    #source_security_group_id = "${aws_security_group.private_subnet.id}"
}

resource "aws_security_group_rule" "HTTPS-outopen-to-public" {
    type = "egress"
    from_port = 443
    to_port = 443
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

/*resource "aws_security_group_rule" "to-private-from-public-icmp-ingress" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "icmp"
    security_group_id = "${aws_security_group.private_subnet.id}"
    source_security_group_id = "${aws_security_group.public_subnet.id}"
}*/

/*resource "aws_security_group_rule" "private-to-public-icmp-egress" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "icmp"
    security_group_id = "${aws_security_group.private_subnet.id}"
    source_security_group_id = "${aws_security_group.public_subnet.id}"
}*/


resource "aws_security_group_rule" "private-to-db-egress" {
    type = "egress"
    from_port = 3306  
    to_port = 3306
    protocol = "tcp"
    security_group_id = "${aws_security_group.private_subnet.id}"
    source_security_group_id = "${aws_security_group.db_subnet1_sg.id}"
}

resource "aws_security_group_rule" "private-to-db-egress2" {
    type = "egress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_group_id = "${aws_security_group.db_subnet2_sg.id}"
    source_security_group_id = "${aws_security_group.private_subnet.id}"
}

resource "aws_security_group_rule" "private-to-public-out-HTTP-traffic" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = "${aws_security_group.private_subnet.id}"
    source_security_group_id = "${aws_security_group.public_subnet.id}"
}

resource "aws_security_group_rule" "private-to-public-out-HTTPS-traffic" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = "${aws_security_group.private_subnet.id}"
    source_security_group_id = "${aws_security_group.public_subnet.id}"
}

resource "aws_security_group" "db_subnet1_sg" {
  vpc_id      = aws_vpc.vpc_test.id
  name        = "db_subnet1_sg"
  description = "private Instances Security Group"
}

resource "aws_security_group_rule" "private-to-db-ingress" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_group_id = "${aws_security_group.db_subnet1_sg.id}"
    source_security_group_id = "${aws_security_group.private_subnet.id}"
}

resource "aws_security_group_rule" "open-to-db-ingress" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_group_id = "${aws_security_group.db_subnet1_sg.id}"
    #source_security_group_id = "${aws_security_group.private_subnet.id}"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "db_subnet2_sg" {
  vpc_id      = aws_vpc.vpc_test.id
  name        = "db_subnet2_sg"
  description = "private Instances Security Group"
}

resource "aws_security_group_rule" "private-to-db-ingress1" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_group_id = "${aws_security_group.db_subnet2_sg.id}"
    source_security_group_id = "${aws_security_group.private_subnet.id}"
}

################################### ROUTING TABLE CREATION START ##################################

resource "aws_route_table" "RT-Internetout_IGW" {
  vpc_id = aws_vpc.vpc_test.id

  route {
    cidr_block = "${var.cidr_block_outside}"
    gateway_id = "${aws_internet_gateway.IGW_Suresbyvpc_test.id}"
  }

  tags = {
    Name = "IGW-route-table-${var.vpc_name}"
    Env = "test"
  }
}

resource "aws_route_table" "RT-public_subnet" {
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

################################### SUBNET ASSOCIATIONS TO ROUTE TABLE ############################

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.RT-Internetout_IGW.id}"
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.RT-public_subnet.id}"
}

resource "aws_route_table_association" "DB_subnet1_association" {
  subnet_id = "${aws_subnet.DB_subnet1.id}"
  route_table_id = "${aws_route_table.RT-public_subnet.id}"
}

resource "aws_route_table_association" "DB_subnet2_association" {
  subnet_id = "${aws_subnet.DB_subnet2.id}"
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

















