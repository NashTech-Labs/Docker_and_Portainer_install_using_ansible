provider "aws" {
  region = "us-east-1"

  access_key = "${var.AccessKey}"
  secret_key = "MOn+VBBXgONFkGq6G/72AmgilK7foZ4VE+5glUV2"
}

# Create a Ec2

resource "aws_instance" "Ec2" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups = [aws_security_group.Docker_SG.name]
  key_name = "docker_key"


  tags = {
    Name = "docker"
  }
}

# Create ssh key

resource "aws_key_pair" "docker_key" {
  key_name   = "docker_key"
  public_key =  tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "docker-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "dockerkey"
}


#ip output
output "ec2_global_ips" {
  value = ["${aws_instance.Ec2.*.public_ip}"]

}

#create security group

resource "aws_security_group" "Docker_SG" {
  name        = "docker_security_group"
  description = "Docker security group"
  vpc_id      = "addvpcid"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Docker_SG"
  }
}