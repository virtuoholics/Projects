This huge IaC project deploys an web-server infrastructure that consists of the following:

- Windows web server instances
- An SQL Server database
- A bastion instance for management and internal access of the resources
- Network Load-Balancer for traffic distribution
- Amazon Certificate Manager public certificates for HTTPS connection to the web-server
- Amazon Route 53 hosted zone for providing a URL/public DNS name to the web-server
- AWS Secrets Manager secrets for RDS password management
- VPC with subnets, Internet-Gateway, NAT-Gateway and routing tables for laying the foundation network

The project is built with Terraform with Terragrunt used as an extra layer of IaC.
