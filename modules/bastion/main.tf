


data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../../terraform.tfstate"
  }
}

terraform {
  backend "local" {
    path = "../modules/bastion/terraform.tfstate"
  }
}

data "aws_region" "current" {}

data "aws_ami" "ubuntu" {
  description = "Ubuntu image for bastion instance"
  most_recent = true
  #name_regex       = "^myami-\\d{3}"
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }


}




resource "aws_instance" "bastion" {
  #count                       = length(data.terraform_remote_state.vpc.outputs.public_subnet_ids)

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "virg.keypair"
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]

  user_data = file("user_data.sh") // Static file


  tags = {
    Name = "bastion-for db"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "The security group for bastion instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "Allow traffic from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr] //Must be edited to allow traffic from Myip via port 22
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
