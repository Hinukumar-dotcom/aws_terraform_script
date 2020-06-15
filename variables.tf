
############################# Variables #####################################################

variable "region" {
    default = "us-east-1"
}

variable "access_key" {
    default = "AKIATRWDODR77UOBTD7O"
} 

variable "secret_key" {
    default = "CfCjkZ5ynN7ihzgDlnum0F6jMmWa9fj+Q+zs6p4A"
}

variable "cidr_block" {
    default = "10.0.0.0/16"
}

variable "vpc_name" {
    default = "Suresbyvpc_test"
}

variable "cidr_block_subnet_1" {
    default = "10.0.1.0/24"
}

variable "cidr_block_subnet_2" {
    default = "10.0.2.0/24"
}

variable "cidr_block_subnet_3" {
    default = "10.0.3.0/24"
}

variable "Availablity_Zone_1" {
    default = "us-east-1a"
}

variable "Availablity_Zone_2" {
    default = "us-east-1b"
}

variable "Availablity_Zone_3" {
    default = "us-east-1c"
}

variable "cidr_block_outside" {
    default = "0.0.0.0/0"
}

