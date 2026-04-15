# Terraform CI/CD Pipeline with GitHub Actions

Automated Terraform CI/CD pipeline using GitHub Actions - plan on PR, apply on merge to main.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [How The Pipeline Works](#how-the-pipeline-works)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [Screenshots](#screenshots)

---

## Overview

This project demonstrates a production-grade CI/CD pipeline that automates Terraform infrastructure provisioning using GitHub Actions. Every code change triggers an automated pipeline — `terraform plan` runs on every Pull Request so teams can review changes before merging, and `terraform apply` runs automatically when code is merged to the main branch. AWS credentials are stored securely as GitHub Secrets — never hardcoded in code.

---

## Architecture

```
Developer pushes code
        │
        ▼
┌─────────────────────────────────────────────────┐
│              GitHub Actions Pipeline             │
│                                                  │
│  ┌─────────────────┐     ┌──────────────────┐   │
│  │  Terraform Plan  │────►│  Terraform Apply  │   │
│  │  (every push &  │     │  (main branch    │   │
│  │   pull request) │     │   pushes only)   │   │
│  └─────────────────┘     └──────────────────┘   │
└─────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────┐
│                  AWS Infrastructure              │
│                                                  │
│   VPC → Subnet → Internet Gateway               │
│   Security Group → EC2 Instance (Ubuntu 22.04)  │
│                                                  │
│   Remote State: S3 + DynamoDB Locking           │
└─────────────────────────────────────────────────┘
```

---

## Features

- Fully automated CI/CD pipeline using GitHub Actions
- `terraform plan` runs automatically on every Push and Pull Request
- `terraform apply` runs automatically only on merge to main
- `terraform fmt` check enforces consistent code formatting
- `terraform validate` catches syntax errors before plan
- AWS credentials stored securely as GitHub Secrets
- Remote state stored in S3 with DynamoDB locking
- Dynamic Ubuntu 22.04 AMI lookup — always uses latest version
- Pipeline jobs are sequential — apply only runs if plan succeeds

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Terraform v1.14.8 | Infrastructure as Code |
| GitHub Actions | CI/CD automation |
| AWS Provider v5.x | AWS resource management |
| Amazon EC2 | Compute instance |
| Amazon VPC | Network isolation |
| Amazon S3 | Remote state storage |
| Amazon DynamoDB | State locking |
| GitHub Secrets | Secure credential storage |

---

## Project Structure

```
terraform-cicd-pipeline/
├── .github/
│   └── workflows/
│       └── terraform.yml      # GitHub Actions pipeline definition
├── main.tf                    # All AWS resources in one file
├── variables.tf               # Input variable declarations
├── outputs.tf                 # Output values after apply
└── .gitignore                 # Excludes sensitive and generated files
```

---

## How The Pipeline Works

The pipeline has two jobs defined in `.github/workflows/terraform.yml`:

### Job 1 — Terraform Plan
Runs on **every push and every pull request** to main:
1. Checkout the code
2. Setup Terraform
3. `terraform init` — initialise backend and providers
4. `terraform fmt -check` — verify code formatting
5. `terraform validate` — check syntax and configuration
6. `terraform plan` — show what will be created/changed/destroyed

### Job 2 — Terraform Apply
Runs **only when code is pushed to main** (not on PRs):
1. Requires Job 1 to pass first (`needs: terraform-plan`)
2. Checkout the code
3. Setup Terraform
4. `terraform init` — initialise backend and providers
5. `terraform apply -auto-approve` — provision infrastructure automatically

**Why this separation?**
Pull Requests only run plan — giving the team a chance to review changes before they hit production. Apply only runs after merge, ensuring no accidental infrastructure changes from unreviewed code.

---

## Prerequisites

- GitHub account
- AWS account with appropriate IAM permissions
- AWS Access Key ID and Secret Access Key
- S3 bucket for remote state storage
- DynamoDB table for state locking

---

## Setup

### 1. Fork or clone this repository

```bash
git clone https://github.com/isaacambi/terraform-cicd-pipeline.git
cd terraform-cicd-pipeline
```

### 2. Create S3 bucket for remote state

```bash
aws s3api create-bucket --bucket devops-terraform-state-isaac --region us-east-1
```

### 3. Create DynamoDB table for state locking

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 4. Add GitHub Secrets

Go to your GitHub repo → **Settings → Secrets and variables → Actions** and add:

| Secret Name | Value |
|-------------|-------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key |

### 5. Push to main to trigger the pipeline

```bash
git push origin main
```

The pipeline will automatically run and provision your infrastructure!

---

## Usage

### Trigger a plan only (Pull Request)
```bash
git checkout -b feature/my-change
# make your changes
git push origin feature/my-change
# open a Pull Request — plan runs automatically
```

### Trigger plan + apply (merge to main)
```bash
git checkout main
git merge feature/my-change
git push origin main
# pipeline runs plan then apply automatically
```

### Destroy infrastructure manually
```bash
terraform init
terraform destroy
```

---

## Infrastructure Provisioned

| Resource | Name | Description |
|----------|------|-------------|
| VPC | cicd-project-vpc | Main network (10.0.0.0/16) |
| Subnet | cicd-project-subnet | Public subnet (10.0.1.0/24) |
| Internet Gateway | cicd-project-igw | Allows internet access |
| Security Group | cicd-project-sg | Allows SSH, HTTP traffic |
| EC2 Instance | cicd-project-server | Ubuntu 22.04 t2.micro |

---

## Screenshots

### 1. GitHub Actions Pipeline Completed
![GitHub Actions Pipeline](https://raw.githubusercontent.com/isaacambi/terraform-cicd-pipeline/main/terraform-cicd/02-actions-completed.png)

### 2. EC2 Instance Created by Pipeline
![EC2 Instance Created](https://raw.githubusercontent.com/isaacambi/terraform-cicd-pipeline/main/terraform-cicd/02-cicd-instance-created.png)

### 3. Terraform Plan Job Steps
![Terraform Plan Steps](https://raw.githubusercontent.com/isaacambi/terraform-cicd-pipeline/main/terraform-cicd/03-steps-for-teraform-plan.png)

### 4. Terraform Apply Job Steps
![Terraform Apply Steps](https://raw.githubusercontent.com/isaacambi/terraform-cicd-pipeline/main/terraform-cicd/04-terraform-apply-steps.png)

### 5. Project Files Structure
![Project Files](https://raw.githubusercontent.com/isaacambi/terraform-cicd-pipeline/main/terraform-cicd/05-project-files.png)

### 6. Terraform Destroy Complete
![Terraform Destroy](https://raw.githubusercontent.com/isaacambi/terraform-cicd-pipeline/main/terraform-cicd/06-terraform-destroy.png)

---

## Author

Isaac Ambi Abraham — Senior DevOps Engineer
[GitHub](https://github.com/isaacambi) | [LinkedIn](https://www.linkedin.com/in/isaac-ambi-012b75135/)
