output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}

output "cluster_name" {
  description = "Nombre del cluster EKS"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint del control plane del cluster EKS"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "CA data del cluster, para construir el kubeconfig"
  value       = aws_eks_cluster.main.certificate_authority
  sensitive   = true
}
