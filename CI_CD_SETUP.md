# CI/CD Pipeline Setup Guide

This project includes automated Terraform and website deployment via GitHub Actions.

## Pipeline Overview

### 1. **Terraform Plan Pipeline** (`terraform-plan.yml`)
**Triggered on:** Push to any branch (except `main`) or Pull Requests to `main`

**Steps:**
- Validates Terraform formatting
- Initializes Terraform
- Validates configuration
- Runs `terraform plan`
- Comments PR with plan output
- Uploads plan artifact

### 2. **Terraform Apply Pipeline** (`terraform-apply.yml`)
**Triggered on:** Push to `main` branch

**Steps:**
- Runs `terraform plan`
- Applies changes with `terraform apply`
- Deploys website files to S3
- Invalidates CloudFront cache
- Comments on commit with deployment details

### 3. **Website Deployment Pipeline** (`deploy-website.yml`)
**Triggered on:** Changes to `index.html` or `styles.css` on `main` branch

**Steps:**
- Deploys updated website files to S3
- Invalidates CloudFront cache
- Notifies on deployment completion

## Setup Instructions

### Step 1: Configure AWS Credentials in GitHub

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add the following secrets:

| Secret Name | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |
| `CLOUDFRONT_DISTRIBUTION_ID` | Your CloudFront distribution ID |

**To get CloudFront Distribution ID:**
```bash
aws cloudfront list-distributions --query 'DistributionList.Items[0].Id' --output text
```

### Step 2: Create a Feature Branch

```bash
git checkout -b feature/update-portfolio
```

### Step 3: Make Changes

Edit `index.html`, `styles.css`, or Terraform files as needed.

### Step 4: Push Changes

```bash
git add .
git commit -m "Update portfolio content"
git push origin feature/update-portfolio
```

**What happens:**
- ✅ GitHub Actions runs `terraform plan`
- ✅ Plan output appears in PR
- ✅ Plan artifact is uploaded

### Step 5: Create Pull Request

1. Go to GitHub repository
2. Click "Compare & pull request"
3. Review the Terraform plan in the PR comments
4. Make any necessary adjustments

### Step 6: Merge to Main

Once approved, merge the PR to `main` branch.

**What happens:**
- ✅ `terraform apply` runs automatically
- ✅ Website files are deployed to S3
- ✅ CloudFront cache is invalidated
- ✅ Deployment details posted to commit

## Workflow Examples

### Example 1: Update Website Content

```bash
# Create feature branch
git checkout -b feature/update-content

# Edit website
nano index.html

# Push changes
git add index.html
git commit -m "Update About section"
git push origin feature/update-content

# Create PR and merge when ready
```

**Result:** Website content automatically deployed to S3 and cached.

### Example 2: Update Terraform Configuration

```bash
# Create feature branch
git checkout -b feature/add-waf

# Update Terraform
nano terraform/s3_cloudfront.tf

# Push changes
git add terraform/
git commit -m "Add CloudFront WAF protection"
git push origin feature/add-waf

# Review plan in PR
# Merge when approved
```

**Result:** Infrastructure automatically updated via `terraform apply`.

### Example 3: Emergency Fix

```bash
# Create hotfix branch
git checkout -b hotfix/fix-header

# Quick fix
nano index.html

# Push and merge
git add index.html
git commit -m "Fix navigation header bug"
git push origin hotfix/fix-header

# Merge quickly to main
```

**Result:** Fix deployed within seconds via CI/CD.

## Security Best Practices

✅ **Implemented in Pipeline:**
- AWS credentials never exposed in logs
- Plan artifacts only retained for 5 days
- Secrets are masked in outputs
- Only main branch can apply changes

✅ **Additional Recommendations:**
- Use IAM role instead of access keys (if possible)
- Rotate AWS access keys regularly
- Enable branch protection on `main`
- Require pull request reviews before merge
- Monitor deployment logs for errors

## Branch Protection Setup (Optional but Recommended)

To enforce safer deployments:

1. Go to repository **Settings** → **Branches**
2. Click "Add rule" under "Branch protection rules"
3. Apply to branch: `main`
4. Enable:
   - ✓ Require a pull request before merging
   - ✓ Require status checks to pass before merging
   - ✓ Require branches to be up to date before merging

## Troubleshooting

### Pipeline Fails: "No valid credential sources found"

**Solution:** Ensure AWS secrets are set correctly in GitHub.

```bash
# Verify secrets are in Settings > Secrets and variables
# Check the secret names match the pipeline file exactly
```

### Plan Shows Unexpected Changes

**Solution:** Review the plan carefully in the PR comment before merging.

```bash
# Run locally to compare
cd terraform
terraform plan -var="domain_name=portfolio.condevelop.net"
```

### CloudFront Cache Not Invalidating

**Solution:** Ensure `CLOUDFRONT_DISTRIBUTION_ID` secret is set.

```bash
# Get distribution ID
aws cloudfront list-distributions \
  --query 'DistributionList.Items[0].[Id,DomainName]' \
  --output text
```

### Slow Pipeline Execution

**Solutions:**
- Pipeline typically takes 3-5 minutes
- Terraform init caching helps after first run
- Use smaller commits to reduce plan time

## Monitoring Deployments

### View Pipeline Status

1. Go to repository **Actions** tab
2. View workflow run details
3. Click individual workflow names to see logs

### Monitor Deployments

```bash
# Check recent deployments
aws cloudfront list-invalidations --distribution-id <ID>

# Verify S3 files uploaded
aws s3 ls s3://konstantinos-gkekas-portfolio/ --recursive

# Check CloudFront cache status
aws cloudfront get-distribution --id <ID>
```

## Common Workflows

### Daily Content Update
```bash
git checkout -b feature/daily-update
# Make changes
git add .
git commit -m "Daily portfolio update"
git push origin feature/daily-update
# Create PR → Merge → Auto-deployed ✅
```

### Infrastructure Change Review
```bash
git checkout -b feature/add-security
# Update terraform/
git add terraform/
git commit -m "Add WAF rules"
git push origin feature/add-security
# Review plan in PR → Discuss → Merge → Auto-applied ✅
```

### Emergency Hotfix
```bash
git checkout -b hotfix/urgent-fix
# Quick fix
git add .
git commit -m "Fix critical issue"
git push origin hotfix/urgent-fix
# Fast track merge → Deployed immediately ✅
```

## Cost Optimization

- GitHub Actions free for public repositories (up to 2,000 minutes/month)
- Workflows run in parallel but are typically fast
- No additional costs for Terraform or S3 deployments
- CloudFront cache invalidations are free

## Support

For issues with the pipeline:
1. Check **Actions** tab for error logs
2. Review workflow file syntax
3. Verify AWS credentials in Secrets
4. Check Terraform state is accessible

For more info on GitHub Actions:
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [AWS Credentials Action](https://github.com/aws-actions/configure-aws-credentials)
