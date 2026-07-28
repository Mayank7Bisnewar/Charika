# Terraform AWS Deployment for Charika

This directory contains Terraform code to provision the AWS infrastructure for the Charika backend.

## What it provisions

- VPC, public subnets, internet gateway, and routing
- ECS cluster and Fargate service
- Application Load Balancer
- ECR repository
- RDS PostgreSQL database
- Secrets Manager secrets for `DATABASE_URL`, `JWT_SECRET_KEY`, and `GOOGLE_MAPS_API_KEY`

## Setup

1. Install Terraform:

```bash
brew install terraform
```

2. Configure AWS CLI:

```bash
aws configure
```

3. Copy the Terraform variables file if you want to customize values:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

4. Edit `terraform/terraform.tfvars` with your AWS settings, JWT secret, and Google Maps API key.

## Deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Destroy

```bash
cd terraform
terraform destroy
```

## Notes

- The Terraform code uses a public ALB to expose the backend service on port 8000.
- The RDS instance is provisioned in the same VPC and is not publicly accessible.
- For production, replace `jwt_secret_key` and database credentials with strong secrets.
