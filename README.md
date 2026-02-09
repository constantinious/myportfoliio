# Personal Portfolio Website with AWS CloudFront & S3

A professional static website showcasing AWS & Terraform expertise, hosted on S3 with CloudFront CDN.

## Features

- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile
- **Modern Styling**: Professional gradient backgrounds and smooth animations
- **Fast & Scalable**: Hosted on S3 with CloudFront CDN
- **Secure**: HTTPS via CloudFront, no public S3 access
- **Infrastructure as Code**: Complete Terraform setup for reproducible deployments
- **Optimized Caching**: Smart cache headers for HTML, CSS, and other assets
- **Automated Deployment**: Simple bash script for syncing to S3 and cache invalidation

## Project Structure

```
my-profile/
├── index.html              # Main website
├── styles.css              # Styling
├── deploy.sh               # Deployment script
├── setup-terraform.sh      # Terraform initialization script
├── README.md               # This file
└── terraform/
    ├── main.tf             # Provider and Terraform config
    ├── variables.tf        # Input variables
    ├── outputs.tf          # Output values
    └── s3_cloudfront.tf    # S3 bucket and CloudFront resources
```

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- Bash shell

## Quick Start

### 1. Initialize Terraform

```bash
chmod +x setup-terraform.sh
./setup-terraform.sh
```

This will:
- Validate your AWS credentials
- Initialize Terraform
- Generate a deployment plan

### 2. Deploy Infrastructure

```bash
cd terraform
terraform apply tfplan
```

This creates:
- S3 bucket for website hosting
- CloudFront distribution for global CDN
- Origin Access Identity for secure S3 access
- Appropriate bucket policies

### 3. Deploy Website Files

```bash
chmod +x deploy.sh
./deploy.sh
```

This will:
- Sync HTML and CSS files to S3
- Optionally invalidate CloudFront cache
- Display your live website URL

## Configuration

### Custom Domain

To use a custom domain:

1. Create an ACM certificate in AWS (us-east-1 region)
2. Update `terraform/variables.tf`:
   ```hcl
   domain_name = "yourdomain.com"
   ```
3. Modify `terraform/s3_cloudfront.tf` to use the certificate and custom domain
4. Run `terraform apply`

### Custom S3 Bucket Name

Update the default in `terraform/variables.tf`:

```hcl
bucket_name = "your-custom-bucket-name"
```

## Deployment

### Manual Deployment

```bash
./deploy.sh
```

### Automated Deployment with CI/CD

You can integrate this with GitHub Actions, GitLab CI, or other CI/CD platforms:

```yaml
# Example: GitHub Actions
- name: Deploy to S3 and CloudFront
  run: |
    chmod +x deploy.sh
    ./deploy.sh ${{ secrets.S3_BUCKET }} ${{ secrets.CLOUDFRONT_ID }}
```

## Monitoring & Maintenance

### View Website Endpoints

```bash
cd terraform
terraform output
```

### Check CloudFront Cache Status

```bash
aws cloudfront get-distribution --id <DISTRIBUTION_ID>
```

### Monitor S3 Bucket

```bash
aws s3 ls s3://your-bucket-name/ --recursive
```

### View Deployment Logs

Check CloudFront access logs and S3 server access logs in the AWS Console.

## Cost Optimization

- S3 storage: ~$0.023/GB/month
- CloudFront: ~$0.085/GB for first 10TB/month (pay-as-you-go)
- Free tier: 1GB S3 storage + 1TB CloudFront/month (first 12 months)

**Estimated monthly cost**: $0-5 USD for low-traffic sites

## Clean Up

To remove all AWS resources:

```bash
cd terraform
terraform destroy
```

## Security

- S3 bucket is private (public access blocked)
- Access only via CloudFront with Origin Access Identity
- HTTPS enforced via CloudFront
- Server-side encryption enabled on S3
- Versioning enabled on S3 for recovery

## Troubleshooting

### CloudFront still shows old content

```bash
# Manually invalidate cache
aws cloudfront create-invalidation --distribution-id <ID> --paths "/*"
```

### Deployment fails due to permissions

Ensure your AWS IAM user has these permissions:
- s3:*
- cloudfront:*
- acm:* (if using custom domain)

### Terraform state issues

If you encounter state issues, you can reset with:

```bash
rm -rf .terraform terraform.tfstate*
terraform init
```

## Support

For issues or questions, email: Konstantinos.gkekas.1@gmail.com

## License

This project is open source and available under the MIT License.
