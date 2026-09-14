# Provider AWS apuntando al emulador local Floci (https://floci.io) en vez de AWS real.
# Floci expone un endpoint API-compatible con AWS en localhost:4566, sin credenciales reales.
provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = var.floci_endpoint
    eks = var.floci_endpoint
    iam = var.floci_endpoint
    sts = var.floci_endpoint
  }
}
