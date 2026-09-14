# Recursos nativos aws_eks_cluster / aws_eks_node_group en vez del módulo
# terraform-aws-modules/eks: Floci emula EKS con un nodo k3s real de fondo,
# y el módulo asume features (p.ej. IRSA/OIDC completo) que aún puede no cubrir
# al 100%. Recursos nativos dan más control para depurar contra el emulador.

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn

  # AWS-0040 (acceso público habilitado): excepción justificada — este
  # proyecto es un laboratorio de práctica contra Floci en local/CI, sin
  # bastion/VPN, así que necesitamos acceso público al endpoint. Se mitiga
  # acotando public_access_cidrs (AWS-0041) en vez de dejarlo abierto a
  # 0.0.0.0/0, y complementando con acceso privado dentro de la VPC.
  #trivy:ignore:AWS-0040
  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
    resources = ["secrets"]
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
  ]
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.private[*].id
  instance_types  = ["m5.4xlarge"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_registry_policy,
  ]
}
