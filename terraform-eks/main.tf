# main.tf

provider "aws" {
  region = var.region # Using the region variable from variables.tf
}

# Create the EFS security group (for private access only from EKS nodes)
resource "aws_security_group" "efs_sg" {
  name        = var.efs_security_group_name
  description = "Allow access to EFS from vpc only"

  ingress {
    from_port   = 2049 # NFS port
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"] # No public access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EKS-Access-EFS"
  }
}

# Create the EKS Cluster
resource "aws_eks_cluster" "example" {
  name     = var.eks_cluster_name
  role_arn = var.eks_cluster_role_arn # Reference the cluster role ARN from terraform.tfvars
  version  = var.eks_version
  vpc_config {
    subnet_ids = var.subnet_ids # Reference subnet IDs from terraform.tfvars
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name  = aws_eks_cluster.example.name
  addon_name    = "aws-ebs-csi-driver"
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.example.name
  addon_name    = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.example.name
  addon_name    = "kube-proxy"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.example.name
  addon_name    = "vpc-cni"
}

resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name  = aws_eks_cluster.example.name
  addon_name    = "aws-efs-csi-driver"
}

# Create EKS Add-on for Pod Identity
resource "aws_eks_addon" "eks_pod_identity" {
  cluster_name = aws_eks_cluster.example.name
  addon_name   = "eks-pod-identity-agent"
}

# Create the EKS Node Group
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = var.eks_node_role_arn # Reference the node role ARN from terraform.tfvars
  subnet_ids      = var.subnet_ids        # Reference subnet IDs from terraform.tfvars

  scaling_config {
    desired_size = var.desired_nodes # Use desired node count from terraform.tfvars
    max_size     = var.max_nodes     # Use max node count from terraform.tfvars
    min_size     = var.min_nodes     # Use min node count from terraform.tfvars
  }

  instance_types = [var.instance_type] # Use instance type from terraform.tfvars
  ami_type       = "AL2_x86_64"        # Amazon Linux 2 AMI

  # Enable EBS and EFS CSI drivers as add-ons
  remote_access {
    ec2_ssh_key = var.ssh_key_name # Optional, if you want SSH access to nodes
  }
}

# Create the EFS file system
resource "aws_efs_file_system" "example" {
  creation_token = var.efs_name

  tags = {
    Name = var.efs_name
  }
}

# Create EFS mount targets in each subnet (private access only)
resource "aws_efs_mount_target" "example" {
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = var.subnet_ids[0] # You can add additional mount targets for other subnets if needed
  security_groups = [aws_security_group.efs_sg.id]

  # Ensuring private access from EKS (within the VPC)
}

resource "aws_efs_mount_target" "example1" {
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = var.subnet_ids[1]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "example2" {
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = var.subnet_ids[2]
  security_groups = [aws_security_group.efs_sg.id]
}

