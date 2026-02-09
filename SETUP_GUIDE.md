# Complete Setup Guide: Portfolio Website on AWS S3 + CloudFront

## Overview

This guide walks you through deploying your professional AWS/Terraform portfolio website using:
- **S3**: Static website hosting
- **CloudFront**: Global CDN for fast content delivery
- **Terraform**: Infrastructure as Code for reproducible deployments

**Estimated setup time**: 15-20 minutes

---

## Step 1: Prerequisites

### Install Required Tools

#### macOS (using Homebrew)

```bash
# Install Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Install AWS CLI
brew install awscli

# Verify installations
terraform version
aws --version
```

#### Linux/Windows
Visit official websites:
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

### Configure AWS Credentials

```bash
# Configure AWS CLI with your credentials
aws configure

# When prompted, enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json

# Verify configuration
aws sts get-caller-identity
```

**Note**: You'll need AWS credentials with permissions for S3, CloudFront, and IAM.

---

## Step 2: Customize Your Configuration

### Update S3 Bucket Name

S3 bucket names must be globally unique. Edit `terraform/terraform.tfvars.example`:

```hcl
bucket_name = "your-unique-bucket-name-here"
```

Then save as `terraform/terraform.tfvars`:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform/terraform.tfvars with your bucket name
```

### Optional: Update Region

Edit `terraform/terraform.tfvars` if you prefer a different AWS region:

```hcl
aws_region = "eu-west-1"  # Use your preferred region
```

---

## Step 3: Initialize & Deploy Infrastructure

### Make scripts executable

```bash
chmod +x setup-terraform.sh
chmod +x deploy.sh
```

### Run Setup Script

```bash
./setup-terraform.sh
```

This will:
1. ✅ Verify AWS credentials
2. ✅ Initialize Terraform
3. ✅ Validate configuration
4. ✅ Generate deployment plan

**Review the plan carefully** before proceeding.

### Deploy Infrastructure

```bash
cd terraform
terraform apply tfplan
cd ..
```

**What gets created:**
- S3 bucket (private)
- CloudFront distribution
- Origin Access Identity (OAI)
- Appropriate bucket policies
- Versioning and encryption

**Estimated creation time**: 5-10 minutes

### Verify Deployment

```bash
cd terraform
terraform output
cd ..
```

You should see:
- S3 bucket name
- CloudFront domain name
- S3 website endpoint

---

## Step 4: Deploy Website Files

```bash
./deploy.sh
```

This script will:
1. ✅ Upload HTML and CSS to S3
2. ✅ Invalidate CloudFront cache
3. ✅ Display your live URLs

**Expected output:**
```
Website is now live at:
  S3 Endpoint: http://bucket-name.s3-website-us-east-1.amazonaws.com
  CloudFront: https://d1234abcd.cloudfront.net
```

---

## Step 5: Verify Your Site

Visit the CloudFront URL provided in the output. You should see:
- ✅ Professional homepage with your info
- ✅ All sections properly formatted
- ✅ Responsive design on mobile
- ✅ Working contact email link

---

## Advanced: Custom Domain Setup

To use your own domain (e.g., yourdomain.com):

### 1. Create SSL Certificate in AWS

```bash
# In AWS Console > Certificate Manager (ACM)
# - Request new certificate
# - Domain: yourdomain.com
# - Add alternative domain: www.yourdomain.com
# - Validate via email
# - Note the certificate ARN
```

### 2. Update Terraform

Edit `terraform/s3_cloudfront.tf` and replace the `viewer_certificate` block:

```hcl
viewer_certificate {
  acm_certificate_arn      = "arn:aws:acm:us-east-1:xxxxx:certificate/xxxxx"
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
}

# Add custom domain alias
aliases = ["yourdomain.com", "www.yourdomain.com"]
```

### 3. Create DNS Records

In your domain registrar (Route53, Namecheap, etc.):

```
Type: CNAME
Name: yourdomain.com
Value: d1234abcd.cloudfront.net (your CloudFront domain)
TTL: 300
```

### 4. Deploy

```bash
cd terraform
terraform apply
cd ..
./deploy.sh
```

---

## CI/CD Integration (GitHub Actions)

Automate deployments on every git push:

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Website

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy to S3 and CloudFront
        run: |
          chmod +x deploy.sh
          ./deploy.sh ${{ secrets.S3_BUCKET }} ${{ secrets.CLOUDFRONT_ID }}
```

Store secrets in GitHub (Settings > Secrets):
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `S3_BUCKET`
- `CLOUDFRONT_ID`

---

## Monitoring & Maintenance

### View CloudFront Performance

```bash
aws cloudfront get-distribution-statistics --id <DISTRIBUTION_ID>
```

### Monitor S3 Bucket

```bash
# List all files
aws s3 ls s3://your-bucket-name --recursive --human-readable --summarize

# Check bucket size
aws s3api list-objects-v2 --bucket your-bucket-name \
  --query 'Contents[].Size' | jq 'add / 1024 / 1024'
```

### CloudFront Cache Invalidation

Clear cache manually if needed:

```bash
aws cloudfront create-invalidation \
  --distribution-id <ID> \
  --paths "/*"
```

---

## Troubleshooting

### Q: CloudFront shows old content

**A**: 
```bash
aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/*"
```

Wait 1-2 minutes for invalidation to complete.

### Q: Deployment fails with permission errors

**A**: Ensure IAM user has these permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "cloudfront:*",
        "iam:GetUser"
      ],
      "Resource": "*"
    }
  ]
}
```

### Q: 404 errors on website

**A**: 
1. Verify files uploaded: `aws s3 ls s3://your-bucket`
2. Check S3 bucket policy allows CloudFront access
3. Verify index.html exists in bucket root
4. Invalidate CloudFront cache

### Q: Terraform state locked

**A**:
```bash
cd terraform
terraform force-unlock <LOCK_ID>
```

### Q: Want to use different AWS region

**A**: Update `terraform/terraform.tfvars`:
```hcl
aws_region = "eu-west-1"
```

Then:
```bash
cd terraform
rm -rf .terraform terraform.lock.hcl
terraform init
terraform apply
```

---

## Cost Estimation

### Monthly Costs

| Service | Usage | Cost |
|---------|-------|------|
| S3 | ~1 GB storage | $0.02 |
| CloudFront | ~100 GB/month | ~$8.50 |
| Data transfer out | Included in CF | - |
| **Total** | - | ~$8.50 |

**For free tier** (first 12 months):
- 1 GB S3 storage
- 1 TB CloudFront bandwidth per month
- **Cost: $0**

### Cost Optimization Tips

- Use CloudFront (more efficient than S3 alone)
- Enable compression (already configured)
- Set smart cache headers (already configured)
- Avoid unnecessary data transfers

---

## Security Best Practices

✅ **Already implemented:**
- S3 bucket is private (public access blocked)
- Access only via CloudFront with OAI
- HTTPS enforced by CloudFront
- AES256 encryption on S3
- Versioning enabled for recovery
- IAM security best practices

✅ **Optional enhancements:**

1. **Enable S3 access logging**:
```hcl
resource "aws_s3_bucket_logging" "website" {
  bucket = aws_s3_bucket.website.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}
```

2. **Enable CloudFront logging**:
```hcl
logging_config {
  include_cookies = false
  bucket          = aws_s3_bucket.logs.bucket_regional_domain_name
  prefix          = "cloudfront-logs/"
}
```

3. **Set up WAF for DDoS protection**:
```bash
# In AWS Console > WAF
# Attach to CloudFront distribution
```

---

## Updating Your Website

### Update HTML content

1. Edit `index.html`
2. Run deployment:
```bash
./deploy.sh
```

### Update CSS styling

1. Edit `styles.css`
2. Run deployment:
```bash
./deploy.sh
```

### Update from Git

```bash
git add .
git commit -m "Update portfolio website"
git push origin main
# If CI/CD configured, deploys automatically
```

---

## Clean Up Resources

To stop incurring charges, destroy all AWS resources:

```bash
cd terraform
terraform destroy
```

⚠️ **Warning**: This permanently deletes:
- S3 bucket and all contents
- CloudFront distribution
- All related configurations

After confirming, your website will no longer be accessible.

---

## Getting Help

### AWS Support

- [AWS Support Center](https://console.aws.amazon.com/support/)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/amazon-web-services)

### Terraform Support

- [Terraform Registry](https://registry.terraform.io/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Terraform Community](https://discuss.hashicorp.com/c/terraform/)

### Contact

For questions about this setup or portfolio services:
📧 Konstantinos.gkekas.1@gmail.com

---

## Next Steps

1. ✅ Deploy your infrastructure
2. ✅ Visit your live website
3. ✅ Share your CloudFront URL with potential clients
4. ✅ Set up custom domain (optional)
5. ✅ Configure CI/CD pipeline (optional)
6. ✅ Monitor CloudFront analytics (optional)

**You're all set! 🚀**

Your professional portfolio is now live on AWS with enterprise-grade infrastructure.
