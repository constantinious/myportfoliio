#!/bin/bash

# Terraform Initialization and Setup Script
# Run this once before deploying the infrastructure

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    log_error "Terraform is not installed. Please install it first."
    log_info "Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    log_error "AWS CLI is not installed. Please install it first."
    log_info "Visit: https://aws.amazon.com/cli/"
    exit 1
fi

TERRAFORM_DIR="$(cd "$(dirname "$0")/terraform" && pwd)"
cd "$TERRAFORM_DIR"

log_info "Terraform version:"
terraform version

log_info "AWS credentials check..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    log_error "AWS credentials not configured. Please configure AWS CLI first."
    log_info "Run: aws configure"
    exit 1
fi

log_info "Initializing Terraform..."
terraform init

log_info "Running Terraform format check..."
terraform fmt -check -recursive . || {
    log_warn "Some files need formatting. Running terraform fmt..."
    terraform fmt -recursive .
}

log_info "Validating Terraform configuration..."
terraform validate

log_info "Generating Terraform plan..."
terraform plan -out=tfplan

log_info "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Review the plan above"
echo "  2. Run 'terraform apply tfplan' to create the infrastructure"
echo "  3. Run './deploy.sh' from the project root to upload files"
