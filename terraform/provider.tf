terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.59.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}


