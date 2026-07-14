output "cluster_name" {
  value = aws_eks_cluster.eks-cl.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks-cl.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.eks-cl.certificate_authority[0].data
}
