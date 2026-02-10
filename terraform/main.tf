terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "konstantinos-gkekas-portfolio-terraform-state"
    key     = "portfolio/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "terraform_user"

  default_tags {
    tags = {
      Project     = "PersonalPortfolio"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "terraform_user"

  default_tags {
    tags = {
      Project     = "PersonalPortfolio"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
