# Infrastructure Documentation

## Deployed Resources

### VPC & Networking
- VPC with public and private subnets across 2 AZs
- Internet Gateway
- NAT Gateways
- Route Tables

### EKS Cluster
- Cluster Name: sock-shop-cluster
- Kubernetes Version: 1.29
- Node Group: 3 nodes (t3.medium)
- Namespaces: sock-shop

### Load Balancer
- Type: Classic Load Balancer (AWS ELB)
- Service: front-end (sock-shop namespace)
- Port: 80

### Microservices Deployed
- front-end
- catalogue, catalogue-db
- carts, carts-db
- orders, orders-db
- payment
- shipping
- user, user-db
- queue-master
- rabbitmq
- session-db

## Access Information
- Application URL: http://adefbdf4c434f45228f1252a0e702a3c-1479386036.ap-south-1.elb.amazonaws.com
