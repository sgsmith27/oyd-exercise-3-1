data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "s3_read_server" {
  statement {
    effect = "Allow"

    actions = ["s3:GetObject"]

    resources = [
      "arn:aws:s3:::${var.app_s3_bucket}/server.rb"
    ]
  }
}

resource "aws_iam_role" "instance" {
  name               = "${var.name}-${var.environment}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy" "s3_read" {
  name   = "${var.name}-${var.environment}-s3-read-server"
  role   = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.s3_read_server.json
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-${var.environment}-profile"
  role = aws_iam_role.instance.name
}

resource "aws_security_group" "this" {
  name        = "${var.name}-${var.environment}-sg"
  description = "Allow HTTP traffic on port 8080 from approved CIDR blocks"

  ingress {
    description = "Allow app traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-${var.environment}-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

locals {
  user_data = <<-EOT
    #!/bin/bash
    dnf install -y ruby awscli
    mkdir -p /opt
    aws s3 cp s3://${var.app_s3_bucket}/server.rb /opt/server.rb
    COMPUTE_TYPE=ec2 nohup ruby /opt/server.rb > /var/log/server.log 2>&1 &
  EOT
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.this.name
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.user_data)

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}