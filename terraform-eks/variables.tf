# variables.tf

variable "region" {
  description = "The AWS region to create the EKS cluster in"
  type        = string
  default     = "us-west-2" # Modify with your desired region
}

variable "eks_cluster_role_arn" {
  description = "The ARN of the custom EKS Cluster Role"
  type        = string
}

variable "eks_node_role_arn" {
  description = "The ARN of the custom EKS Node Role"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs for the EKS cluster"
  type        = list(string)
  default = [
    "subnet-xxxxxxxx", # Replace with actual subnet IDs
    "subnet-yyyyyyyy"  # Replace with actual subnet IDs
  ]
}

variable "ssh_key_name" {
  description = "The SSH key name for EC2 instances in the EKS Node Group (optional)"
  type        = string
  default     = "your-ssh-key-name" # Replace with your actual key name
}

# Instance type for EKS nodes
variable "instance_type" {
  description = "EC2 instance type for the EKS worker nodes"
  type        = string
  default     = "t3.medium" # 2 vCPUs, 4 GB RAM (modify if needed)
}

# Minimum number of nodes in the node group
variable "min_nodes" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 3 # Modify if you need a different minimum size
}

# Maximum number of nodes in the node group
variable "max_nodes" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 5 # Modify if you need a different maximum size
}

# Desired number of nodes in the node group
variable "desired_nodes" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 3 # Modify if you want a different default desired size
}

# EFS configuration
variable "efs_name" {
  description = "The name of the EFS file system"
  type        = string
  default     = "example-efs"
}

# EFS Security Group configuration (used by mount targets)
variable "efs_security_group_name" {
  description = "The name of the security group for EFS"
  type        = string
  default     = "eks-efs-sg"
}

# EKS Cluster Name configuration
variable "eks_cluster_name" {
  description = "The name of the cluster for EKS"
  type        = string
  default     = "eks-monitoring-01"
}

# EKS Node Group Name configuration
variable "eks_node_group_name" {
  description = "The name of the security group for EKS Node"
  type        = string
  default     = "eks-monitoring-ng-01"
}

variable "eks_version" {
  description = "The desired Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.23" # Specify the default version here, for example 1.23
}