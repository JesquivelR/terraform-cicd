terraform {
  backend "s3" {
    bucket  = "jesquivel-tf-bucket"  # Reemplaza con el nombre de tu bucket
    key     = "prod/terraform.tfstate"
    region  = "us-west-1"
    encrypt = true
  }
}
