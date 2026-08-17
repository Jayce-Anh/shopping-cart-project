# Project: Deploy a Microservice Application on AWS EKS with GitLab CI, ArgoCD GitOps, EFK, and Kube-Prometheus

## I. Introduction

### About me

👋 Hi, I'm **Jayce** — a Cloud / DevOps engineer focused on building reliable platforms on AWS and Kubernetes.

This shopping-cart lab is my hands-on project to practice end-to-end delivery: infrastructure as code, CI/CD, GitOps, and observability in a production-like setup.

🛠️ **Focus areas**

| Area | Skills |
| ---- | ------ |
| ☁️ Cloud | AWS (EKS, VPC, ALB, CloudFront, RDS, ElastiCache, SQS, IAM, KMS) |
| 🏗️ IaC | Terraform, modular AWS infrastructure |
| 🔁 CI/CD & GitOps | GitLab CI, OIDC → IAM, ArgoCD, Helm |
| 📦 Containers | Docker, Kubernetes (EKS), ECR |
| 📊 Observability | EFK (Elasticsearch, Fluentd, Kibana), Prometheus, Grafana, Slack alerts |

### About this project

🛒 This project deploys a **shopping-cart microservice** application on **AWS EKS** using:

- 🦊 **GitLab CI/CD** — build, test, and push container images
- 🚀 **ArgoCD GitOps** — sync Helm manifests from Git to the cluster
- 📜 **EFK** — centralized logging (Elasticsearch, Fluentd, Kibana)
- 📈 **Kube-Prometheus** — metrics and dashboards (Prometheus, Grafana)

The goal is a complete path from Terraform infrastructure → CI pipeline → GitOps deploy → logging and monitoring.

**Original codebase (frontend and backend):** [sivaprasadreddy/spring-boot-microservices-series](https://github.com/sivaprasadreddy/spring-boot-microservices-series.git)

> The application services in this lab are based on that repository. Infrastructure, CI/CD, GitOps, and observability layers were built for this project.

## Table of Contents

- [I. Introduction](#i-introduction)
- [II. Overview](#ii-overview)
  - [1. Architecture](#1-architecture)
  - [2. Tech stack](#2-tech-stack)
  - [3. Services](#3-services)
  - [4. Repository](#4-repository)
- [III. Prerequisites](#iii-prerequisites)
  - [AWS account](#aws-account)
  - [Domain](#domain)
  - [GitLab account](#gitlab-account)
  - [Local setup](#local-setup)
- [IV. Deploy Infrastructure](#iv-deploy-infrastructure)
  - [1. Configure Terraform variables](#1-configure-terraform-variables)
  - [2. Setup S3 backend remote state](#2-setup-s3-backend-remote-state)
  - [3. Deploy and configure Route53 Hosted Zone](#3-deploy-and-configure-route53-hosted-zone)
  - [4. Deploy the rest of the services](#4-deploy-the-rest-of-the-services)
  - [5. Setup GitLab](#5-setup-gitlab)
  - [6. Configure GitLab runner for CI/CD](#6-configure-gitlab-runner-for-cicd)
  - [7. Deploy infrastructure with GitLab CI](#7-deploy-infrastructure-with-gitlab-ci)
  - [8. Deploy ArgoCD, EFK, and Kube-Prometheus](#8-deploy-argocd-efk-and-kube-prometheus)
  - [9. Deploy the web application](#9-deploy-the-web-application)
  - [10. Setup monitoring (Kube-Prometheus)](#10-setup-monitoring-kube-prometheus)
  - [11. Setup alerts (Slack)](#11-setup-alerts-slack)
  - [12. Setup logging (EFK)](#12-setup-logging-efk)
- [V. Clean up the lab](#v-clean-up-the-lab)
  - [1. Destroy the lab](#1-destroy-the-lab)
  - [2. Destroy the S3 state bucket (optional)](#2-destroy-the-s3-state-bucket-optional)

## II. Overview

- This lab deploys a shopping-cart microservice app on AWS EKS with GitLab CI, ArgoCD GitOps, EFK logging, and Kube-Prometheus monitoring.
- Terraform provisions the full AWS stack: VPC, EKS, ECR, ALB, CloudFront, RDS, ElastiCache (Valkey), SQS, and supporting IAM, KMS, and Secrets Manager resources.
- Three Spring Boot services (Catalog, Inventory, and Order) run on EKS; a React SPA is served from S3 behind CloudFront.
- GitLab CI builds and pushes images, and ArgoCD syncs Helm manifests from Git so cluster state follows GitOps.
- Observability uses Fluentd → Elasticsearch → Kibana for logs and Prometheus → Grafana for metrics, with optional Slack alerts.
- Access to ArgoCD, Grafana, and Kibana goes through an external ALB with ACM certificates and Route53 DNS.
- The result is an end-to-end path from infrastructure as code through CI/CD, GitOps deployment, and production-style logging and monitoring.

### 1. Architecture

<img src="docs/images/image-architecture.png" alt="Architecture" width="800" />
<img src="docs/images/image-architecture-2.png" alt="Architecture" width="800" />

### 2. Tech stack

| Layer | Tools |
| ----- | ----- |
| Cloud | AWS (VPC, EC2, EKS, ECR, ALB, CloudFront, S3, Route53, ACM, RDS, ElastiCache, SQS, KMS, Secrets Manager, IAM) |
| IaC | Terraform |
| CI/CD | GitLab CI, GitLab OIDC → AWS IAM, EC2 GitLab Runner |
| GitOps | ArgoCD + Helm manifests (`devops/shopping-cart-manifest`) |
| Backend | Java 8, Spring Boot, Maven, MySQL, Valkey/Redis, AWS SQS |
| Frontend | React 18, Vite, nginx; hosted on S3 + CloudFront |
| Logging | EFK (Elasticsearch, Fluentd, Kibana) |
| Monitoring | Kube-Prometheus stack (Prometheus, Grafana), Slack alerts |

### 3. Services

Internet-facing hostnames format should be: `<service>.<env-application_name>.<your-domain>`.Example: `lab-shopping-cart.jayce-lab.works`.

| Service | Port | Public hostname (Example) | Description |
| ------- | ---- | --------------- | ----------- |
| Catalog-service | 4000 | `https://lab-shopping-cart.jayce-lab.works/api/products` | Product catalog API; enriches stock via Inventory; caches with Valkey. **Public** |
| Inventory-service | 5000 | `https://lab-shopping-cart.jayce-lab.works/api/inventory` | Inventory API; consumes order events from SQS. **Public** |
| Order-service | 6000 | `https://lab-shopping-cart.jayce-lab.works/api/orders` | Orders API; publishes order events to SQS. **Public** |
| Web-ui-service | 443 | `https://lab-shopping-cart.jayce-lab.works` | React SPA; CloudFront + S3 (HTTPS). **Public** |
| ArgoCD | 8080 | `https://argocd.lab-shopping-cart.jayce-lab.works` | GitOps console. **IP-restricted** (`allowed_cidrs`) |
| Kibana | 5601 | `https://kibana.lab-shopping-cart.jayce-lab.works` | Log search and dashboards (EFK). **IP-restricted** (`allowed_cidrs`) |
| Grafana | 8090 | `https://grafana.lab-shopping-cart.jayce-lab.works` | Metrics dashboards (Kube-Prometheus). **IP-restricted** (`allowed_cidrs`) |

### 4. Repository

This GitHub repo stores all source code. GitLab CI/CD uses a **separate project per folder**.

```
shopping-cart-project/
├── services/
│   ├── catalog/                 # → GitLab: shopping-cart-catalog
│   ├── inventory/               # → GitLab: shopping-cart-inventory
│   ├── order/                   # → GitLab: shopping-cart-order
│   └── web-ui/                  # → GitLab: shopping-cart-web-ui
├── devops/
│   ├── shopping-cart-infra/     # → GitLab: shopping-cart-infra
│   └── shopping-cart-manifest/  # → GitLab: shopping-cart-manifest
├── docs/
└── README.md
```

- Clone this repository for the source tree.
- Create matching GitLab projects from each folder above.
- Note: You can choose GitHub or GitLab as the source code management and CI/CD system. This lab uses GitLab for CI/CD.

## III. Prerequisites

### AWS account

- Prepare an AWS account and sign in to the AWS Management Console.

<img src="docs/images/image1.png" alt="AWS account console" width="800" />

- Create AWS profile sso in `~/.aws/config` file with the following content:
```
[profile sso]
sso_session = sso
sso_account_id = <your-aws-account-id>
sso_role_name = <your-aws-role-name>
```

```bash
aws sso login --profile <your-aws-profile>
export AWS_PROFILE=<your-aws-profile>
aws sts get-caller-identity

```
<img src="docs/images/image61.png" alt="AWS profile sso" width="800" />

- Optional: If you want to connect to GitLab runner and Bastion instances using SSH instead of Session Manager, create a Key-Pair in the AWS EC2 console, download the private key, and define it in the EC2 module.

<img src="docs/images/image60.png" alt="AWS EC2 Key-Pair" width="800" />
<img src="docs/images/image62.png" alt="AWS EC2 Key-Pair" width="800" />

### Domain

- Buy a domain from a registrar such as Cloudflare, GoDaddy, or Namecheap. Mine is: `jayce-lab.works`.

<img src="docs/images/image2.png" alt="Domain registration" width="800" />

### GitLab account

- This repo stores the source code. Copy each folder into its own GitLab project.
- Create GitLab groups `Services` (catalog, inventory, order, web-ui) and `DevOps` (infra, manifest).
- Each of these must be a separate GitLab project: `shopping-cart-infra`, `shopping-cart-manifest`, `shopping-cart-catalog`, `shopping-cart-inventory`, `shopping-cart-order`, `shopping-cart-web-ui`.

<img src="docs/images/image3.png" alt="GitLab group and repositories" width="800" />

### Local setup

- Clone this repository. Push each `services/` and `devops/` folder to its matching GitLab project.

<img src="docs/images/image7.png" alt="Local repository folder structure" width="300" />

- Install the required tools: AWS CLI, Git, Terraform, Helm, kubectl, and Slack.
- Login to AWS via AWS CLI

<img src="docs/images/image8.png" alt="Installed local tools" width="600" />

## IV. Deploy Infrastructure

### 1. Configure Terraform variables

- Configure the remote state Terraform variables in `devops/shopping-cart-infra/remote-tfstate/terraform.tfvars`. Replace the values with your own.
- Do the same for the root module Terraform variables in `devops/shopping-cart-infra/terraform.tfvars`.

<img src="docs/images/image63.png" alt="Terraform variables" width="800" />

### 2. Setup S3 backend remote state

Set up an S3 backend for Terraform state to avoid deployment conflicts and improve state management. Run this from `devops/shopping-cart-infra/remote-tfstate`.

<img src="docs/images/image9.png" alt="Terraform remote state module" width="600" />

<img src="docs/images/image10.png" alt="S3 Terraform state bucket" width="800" />

### 3. Deploy and configure Route53 Hosted Zone

- From `devops/shopping-cart-infra`, deploy the Route53 hosted zone first:

```bash
cd devops/shopping-cart-infra
terraform apply --target=module.hosted_zone
```

- **Route53:** Manage the root domain `jayce-lab.works`.
- Copy the Route53 hosted zone NS records to your registrar nameservers. Wait until NS propagation completes (about 10–30 minutes) before the next apply.

<img src="docs/images/image12.png" alt="Route53 NS records" width="800" />

<img src="docs/images/image13.png" alt="Custom DNS nameservers" width="800" />

### 4. Deploy the rest of the services

Deploy the remaining modules from `devops/shopping-cart-infra/main.tf` (after Route53 NS is pointed).

```bash
cd devops/shopping-cart-infra
terraform apply
```

| Service | Component | Description |
| ------- | --------- | ----------- |
| Hosted Zone | Route53 public hosted zone | Creates the hosted zone for `jayce-lab.works` |
| ACM | ALB and CloudFront certificates | Issues `*.lab-shopping-cart.jayce-lab.works` (ALB, regional) and `lab-shopping-cart.jayce-lab.works` (CloudFront, `us-east-1`); Terraform creates DNS validation records and waits until both certs are issued |
| VPC | VPC, subnets, IGW, NAT Gateway, route tables | Creates the network in `ap-southeast-1` with 2 AZs, 2 public and 2 private subnets, Internet Gateway, and NAT Gateway |
| KMS | Customer managed keys (CMK) | Encrypts ECR, SQS, RDS, ElastiCache, Secrets Manager, and EKS |
| ECR | Private repositories | Image registries for `catalog`, `inventory`, and `order` (keep last 3 images) |
| Bastion | EC2 Spot (`t3.small`) | Jump host in a public subnet for SSH access to private resources (RDS, EKS API). |
| GitLab Runner | EC2 + user data | EC2 instance that registers and runs GitLab CI jobs. |
| Runner IAM | GitLab OIDC IAM role | Lets GitLab CI assume an AWS role (`AWS_ROLE`) without long-lived keys |
| ALB | External Application Load Balancer | HTTPS load balancer with target groups for catalog, inventory, order, ArgoCD, Grafana, and Kibana |
| CloudFront | CloudFront + S3 origin | Hosts web-ui on S3; alias `lab-shopping-cart.jayce-lab.works`; routes `/api/*` to ALB |
| SQS | `order-events` queue | Async queue for order → inventory event flow (KMS encrypted) |
| RDS | MySQL 8.0 (`db.t4g.micro`, port 3306) | Shared MySQL database in private subnets for the microservices |
| Secrets Manager | App and platform secrets | Stores RDS credentials, Helm git token, GitLab runner token, and addon passwords (ArgoCD, Grafana, Elastic) |
| Valkey | ElastiCache Valkey 7.2 (`cache.t4g.micro`, port 6379) | In-memory cache for catalog and inventory services |
| EKS | EKS 1.35 + managed node group | Kubernetes cluster in private subnets; Spot nodes (`t3`/`t3a.medium`, desired 4, min 2, max 5) |
| Helm | AWS Load Balancer Controller, ArgoCD, cert-manager, Cluster Autoscaler, External Secrets, Pod Identity (inventory, order) | Installs cluster addons: ALB target group binding, GitOps sync from `devops/shopping-cart-manifest`, node autoscaling, Secrets Manager sync, and SQS IAM roles for service accounts |

- Update RDS, Redis endpoints, SQS URLs, S3 bucket name, ... in each services GitLab project **APP_ENV** variable.

### 5. Setup GitLab
- Create an environment `lab` on the protected **main** branch of each GitLab project.

<img src="docs/images/image57.png" alt="GitLab environment" width="800" />

<img src="docs/images/image58.png" alt="GitLab environment" width="800" />

- Update the GitLab CI/CD variables.

<img src="docs/images/image5.png" alt="GitLab service CI/CD variables" width="800" />

<img src="docs/images/image6.png" alt="GitLab infra CI/CD variables" width="800" />

| Variable | Groups / services used | Description |
| -------- | ---------------------- | ----------- |
| APP_ENV | Services | This is the environment variable that is used to identify the environment of the application. Example: **.env.example** file in each service directory. |
| ARGOCD_PASSWORD | Services | Password stored in the `lab-shopping-cart-helm-addon-credentials` secret |
| ARGOCD_URL | Services | Hostname of ArgoCD |
| AWS_ECR | Services | ECR repository ARN |
| AWS_ROLE | Services, DevOps | GitLab OIDC provider IAM role |
| HELM_REPO_URL | Services | HTTPS URL of the `shopping-cart-manifest` GitLab project |
| HELM_REPO_TOKEN | Services | Access token for the `shopping-cart-manifest` GitLab project |
| AWS_REGION | Services, DevOps | AWS region for the project |
| AWS_S3 | Services (web-ui) | Origin S3 bucket ARN |
| AWS_DISTRIBUTION_ID | Services (web-ui) | CloudFront distribution ID |

- In GitLab, create a **Fine-grained token** with scoped to the `shopping-cart-manifest` project with read and write access for commits.

<img src="docs/images/image16.png" alt="GitLab fine-grained access token" width="800" />

<img src="docs/images/image17.png" alt="GitLab fine-grained access token settings" width="800" />

- Paste the token into the `HELM_REPO_TOKEN` variable, then update it in the `lab-shopping-cart-helm-git-token` secret.

<img src="docs/images/image18.png" alt="Helm Git token secret" width="800" />

- The first Terraform apply creates this secret with a placeholder (`replace-me-with-gitlab-token`). ArgoCD Helm can install, but it cannot clone the manifest repo until the real token is in Secrets Manager **and** Terraform has refreshed `argocd-repo-creds` in the cluster.

- After you put the real GitLab token in `lab-shopping-cart-helm-git-token` secret, apply again: Run `terraform apply`, or use **GitLab CI** (if the infra pipeline is setting up successfully at step 7) to commit and push `shopping-cart-infra` to automatically apply the changes.

### 6. Configure GitLab runner for CI/CD

- Authenticate the GitLab OIDC provider with AWS. Use the `lab-shopping-cart-gitlab-runner-provider` ARN to create temporary AWS credentials for the GitLab runner Docker executor. Copy the IAM role ARN into the `AWS_ROLE` variable in each GitLab project that needs AWS.

<img src="docs/images/image19.png" alt="GitLab OIDC IAM role" width="800" />

- Create a group runner in GitLab.

<img src="docs/images/image20.png" alt="Create GitLab group runner" width="800" />

- Register the GitLab runner on EC2 using the runner registration token, then store it in the `lab-shopping-cart-gitlab-runner-token` secret.

``` bash
sudo gitlab-runner register  --url https://gitlab.com  --token <gitlab-runner-registration-token>
# Default: https://gitlab.com -> Press Enter
shopping-cart
docker
alpine:latest
sudo systemctl status gitlab-runner
sudo systemctl start gitlab-runner
sudo systemctl enable gitlab-runner
```

<img src="docs/images/image21.png" alt="GitLab runner registration token" width="800" />

<img src="docs/images/image22.png" alt="Runner token secret" width="800" />

### 7. Deploy infrastructure with GitLab CI

<img src="docs/images/image23.png" alt="Infrastructure pipeline overview" width="800" />

- Push Terraform changes to the `shopping-cart-infra` GitLab project (source: `devops/shopping-cart-infra`).
- Verify the `terraform-plan` job, then run the `terraform-deploy` job manually.

<img src="docs/images/image24.png" alt="Terraform plan and apply jobs" width="800" />

- Confirm the CI/CD pipeline succeeds:

<img src="docs/images/image25.png" alt="Successful infrastructure CI/CD" width="800" />

<img src="docs/images/image4.png" alt="Infrastructure environment deployments" width="800" />

### 8. Deploy ArgoCD, EFK, and Kube-Prometheus

Create Route53 records for the public hostnames (example):

| Hostname | Record | Alias target |
| -------- | ------ | ------------ |
| `lab-shopping-cart.jayce-lab.works` | CNAME | CloudFront (web-ui; `/api/*` goes to ALB) |
| `argocd.lab-shopping-cart.jayce-lab.works` | A (alias) | External ALB |
| `grafana.lab-shopping-cart.jayce-lab.works` | A (alias) | External ALB |
| `kibana.lab-shopping-cart.jayce-lab.works` | A (alias) | External ALB |

- Add a CNAME record for web-ui using the CloudFront alias.

<img src="docs/images/image26.png" alt="CloudFront CNAME record" width="800" />

- Add A records for ArgoCD, Kibana, and Grafana using the ALB alias.

<img src="docs/images/image30.png" alt="ArgoCD Route53 record" width="800" />

<img src="docs/images/image27.png" alt="ALB alias A records" width="800" />

- Copy each service target group ARN and paste it into the `targetGroupArn` fields in the services, logging, and monitoring manifest value files.

<img src="docs/images/image28.png" alt="Target group ARN" width="800" />

<img src="docs/images/image29.png" alt="Manifest targetGroupArn values" width="800" />

- Log in to the ArgoCD console at `argocd.lab-shopping-cart.jayce-lab.works` with user `admin` and the password from the `helm-addon-credentials` secret.

<img src="docs/images/image31.png" alt="ArgoCD login" width="800" />

<img src="docs/images/image32.png" alt="ArgoCD applications" width="800" />

<img src="docs/images/image33.png" alt="ArgoCD application sync" width="800" />

### 9. Deploy the web application

- Commit and push each service GitLab project (source folders under `services/`):

<img src="docs/images/image34.png" alt="Service repository changes" width="800" />

- Verify the service CI/CD pipelines.

<img src="docs/images/image35.png" alt="Catalog service pipeline" width="800" />

<img src="docs/images/image36.png" alt="Inventory service pipeline" width="800" />

<img src="docs/images/image37.png" alt="Order service pipeline" width="800" />

<img src="docs/images/image38.png" alt="Web-ui service pipeline" width="800" />

- Verify application health on the ArgoCD console.

<img src="docs/images/image39.png" alt="ArgoCD application health" width="800" />

<img src="docs/images/image40.png" alt="ArgoCD application details" width="800" />

- Open the application web UI in a browser.

<img src="docs/images/image41.png" alt="Web UI home" width="800" />

<img src="docs/images/image42.png" alt="Web UI product page" width="800" />

### 10. Setup monitoring (Kube-Prometheus)

- Log in with the admin user and password from `lab-shopping-cart-helm-addon-credentials`.

<img src="docs/images/image43.png" alt="Grafana login" width="800" />

<img src="docs/images/image44.png" alt="Grafana dashboard" width="800" />

### 11. Setup alerts (Slack)

- Create a channel named `lab-shopping-cart-alert` in your Slack workspace.

<img src="docs/images/image45.png" alt="Slack alert channel" width="800" />

- Create a Slack API application named `lab-shopping-cart` at [https://api.slack.com/](https://api.slack.com/).

<img src="docs/images/image46.png" alt="Create Slack app" width="800" />

<img src="docs/images/image47.png" alt="Slack app settings" width="800" />

- Go to **Incoming Webhooks** and turn it on.

<img src="docs/images/image48.png" alt="Enable Incoming Webhooks" width="800" />

- Choose **Add New Webhook to Workspace**, select the `lab-shopping-cart` channel, then copy the webhook URL.

<img src="docs/images/image49.png" alt="Add Slack webhook" width="800" />

<img src="docs/images/image50.png" alt="Slack webhook URL" width="800" />

- Update the `lab-shopping-cart-helm-addon-credentials` secret with the Slack webhook URL (`slack_webhook_url`). The first apply stores a placeholder (`replace-me-with-slack-webhook-url`).

<img src="docs/images/image51.png" alt="Update Slack webhook secret" width="800" />

- External Secrets reads this value from AWS. After you put the real webhook URL in Secrets Manager, run `terraform apply`, or use **GitLab CI** (if the infra pipeline is complete at step 7) to commit and push `shopping-cart-infra` to automatically apply the changes.

- Commit and push the `shopping-cart-manifest` GitLab project (source: `devops/shopping-cart-manifest`). Result:

<img src="docs/images/image52.png" alt="Slack alert result" width="800" />

### 12. Setup logging (EFK)

- Log in with the admin user and password from `lab-shopping-cart-helm-addon-credentials`.

<img src="docs/images/image53.png" alt="Kibana login" width="800" />

- Create an index pattern.

<img src="docs/images/image54.png" alt="Create Kibana index pattern" width="800" />

<img src="docs/images/image55.png" alt="Kibana index pattern settings" width="800" />

- Create visualization panels and add them to a dashboard.

<img src="docs/images/image56.png" alt="Kibana dashboard" width="800" />

## V. Clean up the lab

Destroy from `devops/shopping-cart-infra`. Helm and Kubernetes objects must be deleted **while EKS nodes are still running**. If nodes die first, TargetGroupBinding and Helm CRDs keep finalizers and Terraform times out. 

### 1. Destroy the lab

```bash
cd devops/shopping-cart-infra
terraform init
terraform destroy
```

Review the plan. Type `yes` to confirm destroy the lab.

### 2. Destroy the S3 state bucket (optional)

The remote state bucket in `devops/shopping-cart-infra/remote-tfstate` also has `prevent_destroy`. Keep it unless you want to remove all Terraform state.

To delete it, set `prevent_destroy = false` in `modules/s3/remote-state.tf`, then:

```bash
cd devops/shopping-cart-infra/remote-tfstate
terraform destroy
```

## Thanks for reading!
