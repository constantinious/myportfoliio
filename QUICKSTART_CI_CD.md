# Quick Start: CI/CD Pipeline

## 🚀 Setup in 2 Minutes

### Step 1: Add AWS Credentials to GitHub Secrets
Go to repository **Settings** → **Secrets and variables** → **Actions** and add:

```
AWS_ACCESS_KEY_ID = your_access_key
AWS_SECRET_ACCESS_KEY = your_secret_key
CLOUDFRONT_DISTRIBUTION_ID = EKW3EKWU9CU7S
```

### Step 2: Done! You're Ready to Use It

## 📝 How to Use

### Update Website
```bash
# 1. Create feature branch
git checkout -b feature/update-content

# 2. Edit files
nano index.html

# 3. Push to GitHub
git add .
git commit -m "Update content"
git push origin feature/update-content

# 4. GitHub automatically runs terraform plan
# 5. Create PR and merge to main
# 6. GitHub automatically deploys! ✅
```

### Update Infrastructure
```bash
# Same workflow for Terraform files
git checkout -b feature/add-security
nano terraform/s3_cloudfront.tf
git add .
git commit -m "Add WAF"
git push origin feature/add-security
# PR review shows terraform plan
# Merge to apply automatically
```

## 🔄 What Happens Automatically

| Event | Action |
|-------|--------|
| Push to feature branch | ✓ `terraform plan` runs |
| Create/update PR | ✓ Plan comments on PR |
| Merge to main | ✓ `terraform apply` executes |
| Merge to main | ✓ Website files deploy to S3 |
| Merge to main | ✓ CloudFront cache invalidated |

## 📊 View Pipeline Status

Go to **Actions** tab in GitHub to see:
- All workflow runs
- Success/failure status
- Deployment details
- Error logs if needed

## ⚙️ Pipelines Included

1. **terraform-plan.yml** - Validates changes on feature branches
2. **terraform-apply.yml** - Applies changes when merged to main
3. **deploy-website.yml** - Fast deploy for website-only changes

## 🔒 Security Notes

- AWS credentials stored securely in GitHub Secrets
- Never committed to git
- Only visible to authorized users
- Secrets masked in logs
- Main branch requires approval before deploy (optional)

## 🆘 Troubleshooting

**Pipeline not running?**
- Check secrets are set correctly
- Verify branch names match
- Refresh GitHub page

**Deploy failed?**
- Check Actions tab for error logs
- Verify AWS credentials
- Check S3 bucket exists
- Verify CloudFront distribution ID

## 📚 Full Documentation

See `CI_CD_SETUP.md` for complete guide with examples and troubleshooting.
