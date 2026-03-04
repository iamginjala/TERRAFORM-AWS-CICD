# Terraform AWS CI/CD

A GitHub Actions CI/CD pipeline that automates the deployment of AWS infrastructure using Terraform. On pull requests it runs `terraform plan`, and on merges to `main` it runs `terraform apply` — all authenticated via OIDC (no long-lived AWS credentials).

## Architecture

The Terraform code provisions the following AWS resources in `us-east-2`:

```
Internet
    │
    ▼
Application Load Balancer (public subnets)
    │  HTTP :80
    ▼
Auto Scaling Group (private subnets)
    │  EC2 instances running Docker (nginx)
    ▼
NAT Gateways → Internet (outbound only)
```

| Resource | Details |
|---|---|
| VPC | `10.0.0.0/16`, DNS enabled |
| Public Subnets | 2× across `us-east-2a`, `us-east-2b` |
| Private Subnets | 2× across `us-east-2a`, `us-east-2b` |
| Internet Gateway | Attached to VPC |
| NAT Gateways | 1 per AZ with Elastic IPs |
| ALB | Internet-facing, HTTP :80 |
| ASG | EC2 instances in private subnets, ELB health checks |
| Launch Template | Amazon Linux 2, Docker + nginx container |
| Security Groups | ALB (0.0.0.0/0 → :80/:443), ASG (ALB only → :80) |

**Terraform state** is stored in S3 (`us-east-2`) with encryption and S3-native locking enabled.

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── terraform.yml          # Plan on PR, Apply on push to main
│       └── terraform-destroy.yml  # Manual destroy via workflow_dispatch
└── asg-django-app/
    ├── main.tf          # Root module — wires all child modules together
    ├── variables.tf
    ├── outputs.tf
    ├── providers.tf
    ├── backend.tf       # S3 remote state
    ├── terraform.tfvars
    └── modules/
        ├── vpc/
        ├── security_groups/
        ├── alb/
        └── asg/
```

## CI/CD Workflows

### `terraform.yml` — Automated Plan & Apply

| Trigger | Job | Action |
|---|---|---|
| Pull Request → `main` | `terraform-plan` | `terraform init` + `terraform plan` |
| Push to `main` | `terraform-apply` | `terraform init` + `terraform apply --auto-approve` |

### `terraform-destroy.yml` — Manual Destroy

Triggered manually via **Actions → Terraform destroy → Run workflow**.
Runs `terraform destroy --auto-approve` against the full stack.

## Prerequisites

### 1. AWS OIDC Trust

The workflows authenticate to AWS using OIDC — no static credentials required. You need:

1. An **IAM OIDC Identity Provider** for GitHub Actions (`token.actions.githubusercontent.com`) in your AWS account.
2. An **IAM Role** that trusts the OIDC provider and has permissions to manage the required resources (VPC, EC2, ALB, ASG, S3, IAM for instance profiles, etc.).

### 2. S3 Backend Bucket

Create the S3 bucket referenced in [asg-django-app/backend.tf](asg-django-app/backend.tf) before the first run:

```bash
aws s3api create-bucket \
  --bucket deom-for-tfstate-files-0128 \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2

aws s3api put-bucket-encryption \
  --bucket deom-for-tfstate-files-0128 \
  --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
```

### 3. GitHub Secret

| Secret | Value |
|---|---|
| `AWS_ROLE_ARN` | ARN of the IAM role to assume (e.g. `arn:aws:iam::123456789012:role/github-actions-role`) |

Add it under **Settings → Secrets and variables → Actions → New repository secret**.

## Usage

### Deploy (via CI/CD)

1. Create a feature branch and open a pull request → CI runs `terraform plan`.
2. Review the plan output in the Actions tab.
3. Merge the PR → CI automatically runs `terraform apply`.

### Deploy (locally)

```bash
cd asg-django-app
terraform init
terraform plan
terraform apply
```

### Destroy

**Via GitHub Actions:** Go to **Actions → Terraform destroy → Run workflow → Run workflow**.

**Locally:**

```bash
cd asg-django-app
terraform destroy
```

## Variables

Defined in [asg-django-app/variables.tf](asg-django-app/variables.tf) and set in [asg-django-app/terraform.tfvars](asg-django-app/terraform.tfvars):

| Variable | Default | Description |
|---|---|---|
| `region` | `us-east-2` | AWS region |
| `cidr_block` | `10.0.0.0/16` | VPC CIDR |
| `public_subnet_count` | `2` | Number of public subnets |
| `private_subnet_count` | `2` | Number of private subnets |
| `public_subnet_cidr` | `["10.0.1.0/24","10.0.2.0/24"]` | Public subnet CIDRs |
| `private_subnet_cidr` | `["10.0.11.0/24","10.0.12.0/24"]` | Private subnet CIDRs |
| `az` | `["us-east-2a","us-east-2b"]` | Availability zones |
| `instance_type` | `t2.micro` | EC2 instance type for ASG |
