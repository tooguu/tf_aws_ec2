#main.tf

resource "aws_vpc" "tue_vpc" {
	cidr_block           = "10.8.0.0/16"
	instance_tenancy     = "default"
	enable_dns_support   = "true"
	enable_dns_hostnames = "false"
	tags = {
		Name = "tue_test"
	}
}

#InternetGateway
resource "aws_internet_gateway" "tue_gw" {
    vpc_id = "${aws_vpc.tue_vpc.id}" # tue_vpcのid属性を参照
    tags = {
    	Name = "tue_gw"
    }
}

#RouteTable
resource "aws_route_table" "tue_rt" {
  vpc_id = "${aws_vpc.tue_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tue_gw.id}"
  }
  tags = {
    Name = "tue_rt"
  }
}

# Subnet
resource "aws_subnet" "tue_subA" {
  vpc_id = "${aws_vpc.tue_vpc.id}"
  cidr_block = "10.8.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "tue_subA"
  }
}

# SubnetRouteTableAssociation
resource "aws_route_table_association" "tue_subA" {
    subnet_id = "${aws_subnet.tue_subA.id}"
    route_table_id = "${aws_route_table.tue_rt.id}"
}

# Security Group
resource "aws_security_group" "tue_sg" {
    name = "APP_SG"
    vpc_id = "${aws_vpc.tue_vpc.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    description = "tf-tue-sg"
}

# EC2
resource "aws_instance" "tue_t2" {
  ami = "ami-2a69be4c"
  instance_type = "t2.micro"
  disable_api_termination = false
  associate_public_ip_address = true
  key_name                = "sbox-tueno20190607a"
  vpc_security_group_ids  = ["${aws_security_group.tue_sg.id}"]
  subnet_id               = "${aws_subnet.tue_subA.id}"

  # provisioner "remote-exec"{
  #   connection{
  #     type = "ssh"
  #     user = "ec2-user"
  #     key_file = "${var.ssh_key_file}"
  #   }
  #   inline = [
  #     "sudo yum -y update"
  #   ]
  # }
  tags = {
    Name = "tue-ec2"
  }
}
