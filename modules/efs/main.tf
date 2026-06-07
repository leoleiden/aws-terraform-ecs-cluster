# ==========================================
# Elastic File System (EFS) Setup
# ==========================================

# Dynamically fetch the VPC CIDR block to enforce secure networking
data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "efs_sg" {
  name        = "ecs-efs-sg"
  description = "Allow inbound NFS traffic only from within the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    # FIX: Restricted access to VPC internal traffic only (Zero Trust approach)
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "aws_efs" {
  creation_token   = "ecs-shared-efs"
  performance_mode = "generalPurpose"
  encrypted        = true

  tags = {
    Name = "ecs-shared-efs"
  }
}

resource "aws_efs_mount_target" "aws_efs" {
  for_each        = toset(var.subnet_ids)
  file_system_id  = aws_efs_file_system.aws_efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]

  depends_on = [aws_security_group.efs_sg]
}