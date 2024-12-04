# TerraCloud (Terraform) Project: AWS S3 Static Website with Route 53, CloudFront, and WAF

## Overview
This Terraform project automates the deployment of a secure, scalable static website on AWS. It leverages S3 for static file hosting, Route 53 for DNS management, CloudFront for content delivery, and WAF for web application firewall protection. The infrastructure is modularized, making it reusable and maintainable.

---

## Features
1. **S3 Static Website Hosting**:
   - Configures an S3 bucket to host static files.
   - Automatically uploads web content to the bucket.

2. **Route 53 DNS Management**:
   - Sets up a hosted zone for the domain.
   - Configures A and CNAME records pointing to CloudFront.

3. **CloudFront Distribution**:
   - Integrates with the S3 bucket to enable fast content delivery.
   - Enforces HTTPS with a default CloudFront certificate.
   - Custom cache behaviors for optimized content delivery.

4. **Web Application Firewall (WAF)**:
   - Restricts access to traffic from specific countries (e.g., US and Canada).
   - Blocks non-compliant traffic with custom WAF rules.

5. **Best Practices**:
   - Modularized Terraform code for flexibility and reusability.
   - Variables for dynamic configurations.
   - Outputs for key resource details like CloudFront domain and Route 53 zone ID.
   - Environment tagging for resource management.

---

## Project Structure
terraform/  
├── main.tf              # Root configuration to connect modules  
├── variables.tf         # Global variables for the project  
├── outputs.tf           # Outputs for key resource attributes  
├── modules/  
│   ├── s3/              # S3 static website module  
│   │   ├── main.tf  
│   │   ├── variables.tf  
│   │   ├── outputs.tf  
│   ├── route53/         # Route 53 DNS module  
│   │   ├── main.tf  
│   │   ├── variables.tf  
│   │   ├── outputs.tf  
│   ├── cloudfront/      # CloudFront distribution module  
│   │   ├── main.tf  
│   │   ├── variables.tf  
│   │   ├── outputs.tf  
│   ├── waf/             # WAF configuration module  
│       ├── main.tf  
│       ├── variables.tf  
│       ├── outputs.tf  

## Prerequisites

- AWS CLI installed and configured.
- Terraform CLI installed.
- A domain name registered in Route 53 (optional but recommended).

## Usage

1. Clone this repository:
    ```bash
    git clone https://github.com/ClairDeCoder/terracloud.git
    cd terraform/
    ```

2. Initialize Terraform:
    ```bash
    terraform init
    ```

3. Review the plan:
    ```bash
    terraform plan
    ```

4. Apply the configuration:
    ```bash
    terraform apply
    ```

5. Outputs will provide:
- Cloudfront domain name
- S3 bucket domain
- Route 53 hosted zone ID

## Variables

Variable	| Description	| Default
--- | --- | ---
region |	AWS region for deployment |	us-east-1
bucket_name	| Name of the S3 bucket |	www.mywebsite.com
domain_name |	Domain name for Route 53 |	mywebsite.com
environment	| Environment tag for resources |	production

## Outputs

- **S3 Bucket Domain Name:** The URL for the static website hosted on S3.
- **CloudFront Domain Name:** The CloudFront distribution domain for content delivery.
- **Route 53 Zone ID:** The ID of the hosted zone created for DNS records.

## Modules

**S3 Module**
- Configures an S3 bucket for static website hosting.
- Applies bucket policy for public read access.

**Route 53 Module**
- Creates a hosted zone for the specified domain.
- Adds DNS records pointing to CloudFront.

**CloudFront Module**
- Distributes static content globally with caching.
- Enforces HTTPS connections.

**WAF Module**
- Blocks traffic outside specified geographic regions.
- Custom rules for enhanced security.
