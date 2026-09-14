# devsecops-terraform

Proyecto personal de práctica de DevSecOps, centrado en CI/CD con GitHub Actions.

En vez de desplegar contra AWS real, la infraestructura se aplica contra
[Floci](https://floci.io) — un emulador de nube local, API-compatible con AWS,
más ligero que LocalStack (binarios nativos, sin credenciales reales).

## Qué hay aquí

- `infra/`: Terraform que despliega una VPC + cluster EKS (control plane +
  node group) contra el endpoint local de Floci (`localhost:4566`).
- `.github/workflows/ci.yml`: en cada PR, valida formato/sintaxis de
  Terraform (`fmt`, `validate`), lint (`tflint`), escaneo de
  misconfiguraciones IaC (`trivy` config scan) y detección de secretos
  (`gitleaks`).
- `.github/workflows/cd.yml`: en cada push a `main`, levanta Floci en el
  runner, aplica la infra, hace un smoke test (`describe-cluster`,
  `kubectl get nodes`) y destruye todo al final — no hay entorno persistente,
  es un ciclo de validación end-to-end reproducible.

## Uso en local

```bash
# instalar y arrancar Floci
curl -fsSL https://floci.io/install.sh | sh
floci start
eval "$(floci env)"

cd infra
terraform init
terraform apply

# smoke test
aws eks describe-cluster --name devsecops-practice --endpoint-url http://localhost:4566
aws eks update-kubeconfig --name devsecops-practice --endpoint-url http://localhost:4566
kubectl get nodes

terraform destroy
```

## Notas

EKS es el servicio más complejo que emula Floci (usa un nodo k3s real de
fondo). Se usan recursos nativos `aws_eks_cluster`/`aws_eks_node_group` en
vez del módulo `terraform-aws-modules/eks`, para tener más control si
aparecen limitaciones del emulador frente a AWS real.
