# System Architecture

## Overview
This project implements a microservices-based e-commerce application (Sock Shop) on AWS EKS with full DevOps automation.

## Architecture Diagram

See [architecture diagram](diagrams/architecture.md) for visual representation.

## Infrastructure Components

### AWS Resources
- **Region**: ap-south-1 (Mumbai)
- **VPC**: Custom VPC with CIDR 10.0.0.0/16
- **Subnets**: 
  - Public subnets (2 AZs) for Load Balancers
  - Private subnets (2 AZs) for EKS nodes
- **NAT Gateway**: For outbound internet access from private subnets
- **Internet Gateway**: For public subnet internet access

### EKS Cluster
- **Cluster Name**: dev-sock-shop-eks
- **Kubernetes Version**: 1.29
- **Node Group**: 
  - Instance Type: t3.medium
  - Desired Size: 3 nodes
  - Auto-scaling: 2-4 nodes

### Networking
- **Load Balancer**: AWS Elastic Load Balancer (Classic)
- **Service Type**: LoadBalancer for external access
- **Internal DNS**: Kubernetes CoreDNS

## Application Architecture

### Microservices (sock-shop namespace)

| Service | Language | Database | Purpose |
|---------|----------|----------|---------|
| front-end | Node.js | - | Web UI |
| catalogue | Go | MySQL | Product catalog |
| carts | Java | MongoDB | Shopping cart |
| orders | Java | MongoDB | Order processing |
| payment | Go | - | Payment gateway |
| shipping | Java | - | Shipping calculation |
| user | Go | MongoDB | User management |
| queue-master | Java | - | Async task processing |

### Data Stores
- **MongoDB**: Used by carts, orders, user services
- **MySQL**: Used by catalogue service
- **Redis**: Session storage
- **RabbitMQ**: Message queue for async tasks

## Monitoring Stack (monitoring namespace)

### Components
- **Prometheus**: Metrics collection (2 replicas)
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing (2 replicas)
- **Node Exporter**: Node-level metrics (DaemonSet)
- **Kube State Metrics**: Kubernetes object metrics

### Monitoring Flow
1. Prometheus scrapes metrics from:
   - Kubernetes API server
   - Node exporters (system metrics)
   - Kube-state-metrics (K8s objects)
   - Application pods (if instrumented)
2. Grafana queries Prometheus for visualization
3. Alertmanager handles alert notifications

## Security

### Network Security
- Private subnets for application workloads
- Security groups restricting traffic
- No public IPs on worker nodes

### Access Control
- IAM roles for EKS nodes
- Kubernetes RBAC for pod permissions
- Service accounts for workload identity

## High Availability

### Infrastructure
- Multi-AZ deployment (2 availability zones)
- Auto-scaling node groups
- Managed control plane (EKS)

### Application
- Multiple replicas for stateless services
- Pod anti-affinity for distribution
- Liveness and readiness probes

## Technology Stack

- **Infrastructure**: Terraform, AWS
- **Orchestration**: Kubernetes (EKS)
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus, Grafana
- **Container Registry**: Docker Hub
