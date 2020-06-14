
resource "aws_instance" "Amazon_linux" {

    ami = "ami-01d025118d8e760db"
    instance_type = "t2.micro"
    key_name = "hinukumar_testing"
    subnet_id = "${aws_subnet.public_subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.public_subnet.id}"]
    associate_public_ip_address = "true"

    tags = {
        Name = "Amazon_linux"
        Env = "test"
        owner = "Hinukumar"
    }
} 


resource "aws_instance" "Amazon_linux-2" {

    ami = "ami-01d025118d8e760db"
    instance_type = "t2.micro"
    key_name = "hinukumar_testing"
    subnet_id = "${aws_subnet.private_subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.private_subnet.id}"]
    associate_public_ip_address = "false"

    tags = {
        Name = "Amazon_linux-2"
        Env = "test"
        owner = "Hinukumar"
} 
}


