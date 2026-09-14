variable "region" {
  description = "Región AWS a simular"
  type        = string
  default     = "us-east-1"
}

variable "floci_endpoint" {
  description = "Endpoint local del emulador Floci"
  type        = string
  default     = "http://localhost:4566"
}

variable "cluster_name" {
  description = "Nombre del cluster EKS"
  type        = string
  default     = "devsecops-practice"
}

variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Número de availability zones a usar para las subnets"
  type        = number
  default     = 2
}

variable "cluster_endpoint_public_access_cidrs" {
  description = <<-EOT
    CIDRs permitidos para acceder al endpoint público del cluster EKS.
    En un entorno real esto se restringiría a tu VPN/oficina; aquí se deja
    acotado a redes privadas (RFC1918) en vez de 0.0.0.0/0, ya que contra
    Floci se accede en local/CI sin una IP pública fija conocida.
  EOT
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "tags" {
  description = "Tags comunes aplicadas a todos los recursos"
  type        = map(string)
  default = {
    Project     = "devsecops-terraform"
    Environment = "local-floci"
    ManagedBy   = "terraform"
  }
}
