# Use EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name        = "${var.environment}-${var.project_name}-eks"
  cluster_version     = "1.29"
  vpc_id              = aws_vpc.main.id
  private_subnet_ids  = aws_subnet.private[*].id
  node_instance_types = ["t3.small"]
  desired_size        = 3
  min_size            = 1
  max_size            = 4
}
