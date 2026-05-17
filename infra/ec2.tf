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
# FRONTEND EC2
# =========================

resource "aws_instance" "frontend" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public_subnet.id

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  key_name = var.key_pair_name

  vpc_security_group_ids = [
    aws_security_group.frontend_sg.id
  ]

  user_data = <<-EOF
    #!/bin/bash

    yum update -y
    yum install -y docker git

    systemctl start docker
    systemctl enable docker
  EOF

  tags = {
    Name = "${var.project_name}-frontend"
  }
}

# =========================
# BACKEND EC2
# =========================

resource "aws_instance" "backend" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.private_subnet.id

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  key_name = var.key_pair_name

  vpc_security_group_ids = [
    aws_security_group.backend_sg.id
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
    Name = "${var.project_name}-backend"
  }
}

# =========================
# MYSQL EC2
# =========================

resource "aws_instance" "mysql" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public_subnet.id

  key_name = var.key_pair_name

  vpc_security_group_ids = [
    aws_security_group.mysql_sg.id
  ]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y

    # instalar docker
    yum install -y docker

    systemctl start docker
    systemctl enable docker

    # esperar docker listo
    sleep 10

    # correr mysql automáticamente
    docker run -d \
      --name mysql \
      -e MYSQL_ROOT_PASSWORD=123456 \
      -e MYSQL_DATABASE=ecommerce \
      -p 3306:3306 \
      mysql:8
  EOF

  tags = {
    Name = "${var.project_name}-mysql"
  }
}