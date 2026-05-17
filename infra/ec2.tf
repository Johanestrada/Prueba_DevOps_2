# =========================
# AMAZON LINUX AMI
# =========================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# =========================
# MYSQL EC2
# =========================

resource "aws_instance" "mysql" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.private_subnet.id

  key_name = var.key_pair_name

  vpc_security_group_ids = [
    aws_security_group.mysql_sg.id
  ]

  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash

    yum update -y
    yum install -y docker git

    systemctl start docker
    systemctl enable docker
  EOF

  tags = {
    Name = "${var.project_name}-mysql"
  }
}