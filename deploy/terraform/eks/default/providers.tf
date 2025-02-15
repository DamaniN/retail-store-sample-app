terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
  backend "s3" {
    profile              = "test-test-account"
    bucket               = "xspm-poc-terraform-backend-state"
    key                  = "aws_retail-store-sample-app_eks.tfstate"
    region               = "us-west-2"

    dynamodb_table = "xspm-poc-terraform-states-lock-table"
  }
}

provider "aws" {
  profile = "${terraform.workspace}-test-account"
  region = "us-west-2"
}

provider "aws" {
  alias = "secrets"
  profile = "test-test-account"
  region = "us-west-2"
}

provider "kubernetes" {
  host                   = module.retail_app_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.retail_app_eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "kubernetes" {
  alias = "cluster"

  host                   = module.retail_app_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.retail_app_eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.retail_app_eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(module.retail_app_eks.cluster_certificate_authority_data)
  }
}