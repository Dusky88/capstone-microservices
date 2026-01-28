# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_node_group_id" {
  description = "EKS node group ID"
  value       = module.eks.node_group_id
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS instance address"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "application_url" {
  description = "URL to access the Sock Shop application"
  value       = "http://${aws_lb.main.dns_name}"
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb.id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster"
  value       = module.eks.cluster_security_group_id
}

# Deployment Summary
output "deployment_summary" {
  description = "Deployment summary"
  value       = <<-EOT
    ============================================
    🚀 Sock Shop Infrastructure Deployed (EKS)
    ============================================
    
    Region: ${var.aws_region}
    Environment: ${var.environment}
    
    📦 VPC:
      - VPC ID: ${aws_vpc.main.id}
      - CIDR: ${aws_vpc.main.cidr_block}
      - Public Subnets: ${length(aws_subnet.public)}
      - Private Subnets: ${length(aws_subnet.private)}
    
    ☸️  EKS Cluster:
      - Name: ${module.eks.cluster_name}
      - Endpoint: ${module.eks.cluster_endpoint}
      - Node Group: ${module.eks.node_group_id}
    
    🗄️  RDS Database:
      - Endpoint: ${aws_db_instance.main.endpoint}
      - Database: ${aws_db_instance.main.db_name}
      - Engine: ${aws_db_instance.main.engine} ${aws_db_instance.main.engine_version}
    
    🌐 Load Balancer:
      - DNS: ${aws_lb.main.dns_name}
      - Application URL: http://${aws_lb.main.dns_name}
    
    ============================================
    📝 Next Steps:
    1. Configure kubectl:
       ${module.eks.cluster_name != "" ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}" : ""}
    
    2. Verify nodes:
       kubectl get nodes
    
    3. Deploy Sock Shop:
       kubectl create namespace sock-shop
       kubectl apply -n sock-shop -f https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml?raw=true
    
    4. Expose service:
       kubectl -n sock-shop patch svc front-end -p '{"spec":{"type":"LoadBalancer"}}'
    
    5. Get application URL:
       kubectl -n sock-shop get svc front-end
    ============================================
  EOT
}
