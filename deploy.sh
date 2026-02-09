#!/bin/bash

# Portfolio Website Deployment Script
# This script deploys the website to S3 and optionally invalidates CloudFront cache

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
WEBSITE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TERRAFORM_DIR="${WEBSITE_DIR}/terraform"
BUCKET_NAME="${1:-}"
CLOUDFRONT_ID="${2:-}"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    log_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Get bucket name from Terraform if not provided
if [ -z "$BUCKET_NAME" ]; then
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform CLI not found and no bucket name provided."
        log_error "Usage: ./deploy.sh [BUCKET_NAME] [CLOUDFRONT_ID]"
        exit 1
    fi
    
    log_info "Retrieving S3 bucket name from Terraform..."
    cd "$TERRAFORM_DIR"
    BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
    cd - > /dev/null
    
    if [ -z "$BUCKET_NAME" ]; then
        log_error "Could not retrieve bucket name from Terraform. Please run 'terraform apply' first."
        exit 1
    fi
fi

# Get CloudFront distribution ID if not provided
if [ -z "$CLOUDFRONT_ID" ]; then
    log_info "Retrieving CloudFront distribution ID from Terraform..."
    cd "$TERRAFORM_DIR"
    CLOUDFRONT_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null || echo "")
    cd - > /dev/null
fi

log_info "Starting deployment..."
log_info "Bucket: $BUCKET_NAME"
[ -n "$CLOUDFRONT_ID" ] && log_info "CloudFront Distribution: $CLOUDFRONT_ID"

# Sync files to S3
log_info "Uploading files to S3..."
aws s3 sync "$WEBSITE_DIR" "s3://${BUCKET_NAME}/" \
    --exclude "terraform/*" \
    --exclude ".git/*" \
    --exclude ".gitignore" \
    --exclude "*.md" \
    --exclude "deploy.sh" \
    --delete

log_info "Files uploaded successfully!"

# Invalidate CloudFront cache if distribution ID is available
if [ -n "$CLOUDFRONT_ID" ]; then
    log_info "Invalidating CloudFront cache..."
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
        --distribution-id "$CLOUDFRONT_ID" \
        --paths "/*" \
        --query 'Invalidation.Id' \
        --output text)
    
    log_info "Invalidation created: $INVALIDATION_ID"
    log_info "Cache invalidation in progress..."
else
    log_warn "CloudFront distribution ID not found. Cache will not be invalidated."
fi

log_info "Deployment complete!"
echo ""
echo "Website is now live at:"
echo "  S3 Endpoint: http://${BUCKET_NAME}.s3-website-us-east-1.amazonaws.com"
if [ -n "$CLOUDFRONT_ID" ]; then
    CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution --id "$CLOUDFRONT_ID" --query 'Distribution.DomainName' --output text)
    echo "  CloudFront: https://${CLOUDFRONT_DOMAIN}"
fi
