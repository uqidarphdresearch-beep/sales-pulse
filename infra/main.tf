terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

variable "github_user" {
  description = "Your GitHub username in lowercase"
  type        = string
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "sales-pulse-key"
  public_key = file("~/.ssh/sales_pulse.pub")
}

resource "aws_security_group" "web" {
  name        = "sales-pulse-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    usermod -aG docker ubuntu
    docker run -d --name sales-pulse --restart always -p 80:5000 ghcr.io/${var.github_user}/sales-pulse:latest
  EOT

  tags = { Name = "sales-pulse" }
}

output "app_url" {
  value = "http://${aws_instance.app.public_ip}"
}
