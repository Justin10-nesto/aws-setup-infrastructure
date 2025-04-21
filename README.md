# AWS Setup Infrastructure for Todo Application

This repository contains Terraform configuration for setting up a complete AWS infrastructure to deploy a Todo application. The infrastructure is designed to be secure, scalable, and highly available.

## Architecture Overview

The architecture consists of the following components:

1. **VPC and Networking**
   - Custom VPC with public and private subnets across two availability zones
   - Internet Gateway for public subnet connectivity
   - NAT Instance for private subnet internet access
   - Route tables and security groups for network traffic control

2. **Compute Resources**
   - EC2 instance running the Todo application in Docker containers
   - Auto-configured with user data script to set up the application

3. **Database**
   - PostgreSQL database running in a Docker container
   - Option to use Amazon RDS for managed database service

4. **API Gateway**
   - REST API Gateway to route external requests to the application
   - Configured with CloudWatch logging and CORS support

5. **IAM and Security**
   - IAM roles and policies for EC2 and CloudWatch
   - Security groups for EC2 and database access control
   - SSH key pair for secure instance access

## Infrastructure Diagram

```
                                  +-----------------+
                                  |                 |
                                  |  API Gateway    |
                                  |                 |
                                  +--------+--------+
                                           |
                                           v
+--------------------------------------------------------------------------------------------------+
|                                         VPC                                                      |
|  +----------------+              +----------------+             +----------------+               |
|  |                |              |                |             |                |               |
|  | Public Subnet  +------------->+ NAT Instance   |             | Public Subnet  |               |
|  |     AZ1        |              |                |             |     AZ2        |               |
|  |                |              +-------+--------+             |                |               |
|  +----------------+                      |                      +----------------+               |
|                                          |                                                       |
|  +----------------+                      |                      +----------------+               |
|  |                |                      v                      |                |               |
|  | Private Subnet +<---------------------+----------------------+ Private Subnet |               |
|  |     AZ1        |                                             |     AZ2        |               |
|  |                |                                             |                |               |
|  +----------------+                                             +----------------+               |
|                                                                                                  |
+--------------------------------------------------------------------------------------------------+
                |
                |
                v
       +------------------+
       |   EC2 Instance   |
       |                  |
       | +--------------+ |
       | |  Docker      | |
       | |  - Web App   | |
       | |  - Database  | |
       | |  - Traefik   | |
       | +--------------+ |
       +------------------+
```

## Modules

The infrastructure is organized into the following modules:

### VPC Module

Creates the VPC, subnets, route tables, and security groups. It also provisions a NAT instance to allow private subnets to access the internet.

### EC2 Module

Provisions the EC2 instance that runs the Todo application. It uses user data to install Docker, clone the application repository, and start the containers.

### IAM Module

Creates the necessary IAM roles and policies for the EC2 instance and CloudWatch logging.

### API Gateway Module

Sets up an API Gateway that acts as a facade for the application, providing a secure and scalable API endpoint.

### RDS Module (Optional)

Can be enabled to provision an Amazon RDS instance for the database instead of using a Docker container.

## Deployment

The infrastructure is deployed using Terraform, which creates and configures all the resources in the correct order.

### Prerequisites

- AWS account with appropriate permissions
- Terraform installed locally
- SSH key pair for EC2 instance access

### Deployment Steps

1. Clone this repository
2. Configure AWS credentials
3. Review and update variables in `variables.tf` if needed
4. Run `terraform init` to initialize the Terraform configuration
5. Run `terraform plan` to preview the changes
6. Run `terraform apply` to deploy the infrastructure

## Security Considerations

- All sensitive data is stored as sensitive variables in Terraform
- Security groups restrict traffic to only necessary ports
- SSH access can be restricted to specific IP addresses
- IAM roles follow the principle of least privilege

## Cost Optimization

- Uses t3.micro instances for cost efficiency
- NAT Instance instead of NAT Gateway for cost savings
- Resources are tagged for better cost allocation

## Maintenance

- Update the infrastructure by modifying the Terraform code and running `terraform apply`
- SSH into the EC2 instance for maintenance tasks
- Monitor the application through CloudWatch logs

## Future Improvements

- Implement Auto Scaling Group for high availability
- Add CloudFront distribution for content delivery
- Set up Route 53 for DNS management
- Implement AWS Certificate Manager for SSL/TLS