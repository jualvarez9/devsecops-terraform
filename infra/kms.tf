resource "aws_kms_key" "eks_secrets" {
  description         = "Cifrado de los secrets de Kubernetes en ${var.cluster_name}"
  enable_key_rotation = true

  tags = var.tags
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}
