terraform {  
  backend "s3" {  
    bucket       = "jesquivel-bucket-cicd"  
    key          = "CICD/terraform.tfstate"  
    region       = "us-west-1"  
    encrypt      = true
    use_lockfile = true
  }  
}