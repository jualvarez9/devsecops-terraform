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
- `.github/workflows/cd.yml`: en cada push a `main`, aplica la infra contra
  Floci y hace un smoke test (`describe-cluster`, `kubectl get nodes`). Corre
  en un **self-hosted runner** en local (ver más abajo), no en un runner de
  GitHub — así el pipeline despliega contra tu propio Floci local persistente
  en vez de contra una copia efímera y aislada dentro de una VM de GitHub.

## Uso en local

```bash
# levantar Floci
docker compose up -d

cd infra
terraform init
terraform apply

# smoke test
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566
aws eks describe-cluster --name devsecops-practice
aws eks update-kubeconfig --name devsecops-practice
kubectl get nodes

terraform destroy
```

## Self-hosted runner (para que cd.yml despliegue en local)

`cd.yml` necesita hablar con `localhost:4566`, así que corre en un runner
registrado en la propia máquina en vez de en un runner de GitHub:

```bash
mkdir -p ~/actions-runner-devsecops && cd ~/actions-runner-devsecops
# descargar la versión de https://github.com/actions/runner/releases y extraer

TOKEN=$(gh api -X POST repos/<owner>/<repo>/actions/runners/registration-token --jq '.token')
./config.sh --url https://github.com/<owner>/<repo> --token "$TOKEN" \
  --name floci-local --labels self-hosted-floci --work _work --unattended

./run.sh   # queda escuchando jobs; usar nohup/systemd para dejarlo en background
```

El runner reutiliza las herramientas ya instaladas en tu máquina (`terraform`,
`aws`, `kubectl`) y solo se dispara con jobs que tengan
`runs-on: [self-hosted-floci]` — en este repo, únicamente `cd.yml`. `ci.yml`
sigue en runners normales de GitHub (`ubuntu-latest`), ya que corre también
en PRs y no queremos ejecutar código de PRs arbitrarios en la propia máquina.

## Notas

EKS es el servicio más complejo que emula Floci (usa un nodo k3s real de
fondo). Se usan recursos nativos `aws_eks_cluster`/`aws_eks_node_group` en
vez del módulo `terraform-aws-modules/eks`, para tener más control si
aparecen limitaciones del emulador frente a AWS real.
