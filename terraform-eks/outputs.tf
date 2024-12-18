# Output the EFS DNS name for mounting from the EKS pods
output "efs_dns_name" {
  value = aws_efs_file_system.example.dns_name
}

# Output EKS Cluster Name
output "eks_cluster_name" {
  value = aws_eks_cluster.example.name
}

# Output Node Group Name
output "eks_node_group_name" {
  value = aws_eks_node_group.example.node_group_name
}

# Output EFS Security Group ID
output "efs_sg_id" {
  description = "The ID of the security group for EFS"
  value       = aws_security_group.efs_sg.id
}

# Output EFS File System ID
output "efs_file_system_id" {
  description = "The ID of the created EFS file system"
  value       = aws_efs_file_system.example.id
}