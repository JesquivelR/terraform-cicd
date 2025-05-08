config {
  call_module_type = "local"
}

# Plugin para reglas específicas de AWS
plugin "aws" {
  enabled = true
  version = "0.39.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Reglas generales de Terraform
plugin "terraform" {
  enabled = true
  version = "0.12.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

# Reglas básicas
rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
  style = "semver" # Exige versiones semánticas en módulos
}

rule "terraform_naming_convention" {
  enabled = true
  format = "snake_case" # Requiere snake_case para todos los nombres
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

# Reglas específicas de AWS
rule "aws_resource_missing_tags" {
  enabled = true
  tags = ["Environment", "Owner", "Project"]
}

rule "aws_s3_bucket_name" {
  enabled = true
  regex  = "^[a-z0-9.-]+$" # Cumple con naming convention de S3
}

rule "aws_iam_policy_document_gov_friendly" {
  enabled = true
}

rule "aws_route_not_specified_target" {
  enabled = true
}

# Configuración específica para tu caso
rule "terraform_workspace_remote" {
  enabled = true # Verifica que se use backend remoto
}

rule "var_without_type" {
  enabled = true # Obliga a definir tipo en variables
}

rule "var_without_description" {
  enabled = false # Opcional: Habilitar si quieres descripciones obligatorias
}