# Sock Shop Microservices - DevOps Capstone Project

CI/CD Pipeline (https://github.com/Dusky88/capstone-microservices/blob/main/.github/workflows/ci-cd-pipeline.yaml)

A production-grade microservices deployment demonstrating complete DevOps lifecycle implementation with Infrastructure as Code, CI/CD automation, container orchestration, and comprehensive monitoring.

## Project Overview

This project implements a full DevOps pipeline for the [Weaveworks Sock Shop](https://microservices-demo.github.io/) - a microservices-based e-commerce application. It showcases:

- **Infrastructure as Code** using Terraform
- **Container Orchestration** with Kubernetes (AWS EKS)
- **CI/CD Pipeline** with GitHub Actions
- **Monitoring & Observability** using Prometheus and Grafana
- **Cloud-Native Architecture** on AWS

## Table of Contents

- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring](#monitoring)
- [Project Structure](#project-structure)
- [Screenshots](#screenshots)
- [Lessons Learned](#lessons-learned)

1 🏛️ Architecture

### System Architecture
![Architecture Diagram](docs/diagrams/architecture.md)

2 Infrastructure Components
- **Cloud Provider**: AWS (ap-south-1)
- **Kubernetes**: Amazon EKS cluster with 3 worker nodes
- **Networking**: Custom VPC with public/private subnets across 2 AZs
- **Load Balancer**: AWS Elastic Load Balancer
- **Monitoring**: Prometheus + Grafana stack

3 Application Services
| Service | Description | Database |
|---------|-------------|----------|
| front-end | User interface | - |
| catalogue | Product catalog | MongoDB |
| carts | Shopping cart | MongoDB |
| orders | Order processing | MongoDB |
| payment | Payment processing | - |
| shipping | Shipping management | - |
| user | User management | MongoDB |
| queue-master | Async task processing | RabbitMQ |

4 Technologies Used

# Infrastructure & Cloud
- **Terraform** - Infrastructure as Code
- **AWS EKS** - Managed Kubernetes
- **AWS VPC** - Network isolation
- **AWS ELB** - Load balancing

# Container & Orchestration
- **Docker** - Containerization
- **Kubernetes** - Container orchestration
- **Helm** - Kubernetes package manager

# CI/CD
- **GitHub Actions** - Automation pipeline
- **kubectl** - Kubernetes CLI

# Monitoring
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **Alertmanager** - Alert management

# Version Control
- **Git** - Source control
- **GitHub** - Repository hosting

5 Prerequisites

Before you begin, ensure you have the following installed:

- [AWS CLI](https://aws.amazon.com/cli/) (v2.x)
- [Terraform](https://www.terraform.io/downloads) (v1.0+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (v1.29+)
- [Helm](https://helm.sh/docs/intro/install/) (v3.x)
- [Git](https://git-scm.com/downloads)

6 AWS Account Requirements
- AWS account with appropriate permissions
- IAM user with EKS, VPC, EC2, and ELB permissions
- AWS credentials configured locally


7 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/Dusky88/capstone-microservices.git
cd capstone-microservices
```

### 2. Deploy Infrastructure
```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### 3. Configure kubectl
```bash
aws eks update-kubeconfig --name dev-sock-shop-eks --region ap-south-1
```

### 4. Deploy Application
```bash
kubectl apply -f deploy/kubernetes/complete-demo.yaml
```

### 5. Get Application URL
```bash
kubectl -n sock-shop get svc front-end
# Access the EXTERNAL-IP in your browser
```

## 📚 Detailed Setup

See [SETUP.md](docs/SETUP.md) for comprehensive setup instructions.

## CI/CD Pipeline

![CI/CD Pipeline](docs/diagrams/cicd-pipeline.md)

### Pipeline Workflow

**On Pull Request:**
1. Validate Kubernetes manifests
2. Deploy to staging environment
3. Run tests

**On Merge to Main:**
1. Validate manifests
2. Deploy to production
3. Verify deployment
4. Report status

### GitHub Actions Configuration

The pipeline is defined in `.github/workflows/ci-cd-pipeline.yaml`:
```yaml
Triggers:
  - Push to main/master branches
  - Pull requests
  - Manual workflow dispatch

Jobs:
  - validate: YAML manifest validation
  - deploy-staging: PR deployments
  - deploy-production: Main branch deployments
```

See [CICD.md](docs/CICD.md) for detailed pipeline documentation.

## 📊 Monitoring

### Prometheus + Grafana Stack

**Access Monitoring:**
```bash
# Get Grafana URL
kubectl get svc prometheus-grafana -n monitoring

# Default credentials
Username: admin
Password: admin123
```

### Pre-configured Dashboards
- Kubernetes Cluster Overview
- Pod CPU/Memory Usage
- Node Metrics
- Application Performance

### Configured Alerts
- High CPU usage (>80% for 5 minutes)
- Pod down (unavailable for 1 minute)
- High memory usage (>90% for 5 minutes)
- Frequent pod restarts

See [MONITORING.md](docs/MONITORING.md) for details.

8 📁 Project Structure
```
.
├── .github/
│   └── workflows/
│       └── ci-cd-pipeline.yaml      # GitHub Actions workflow
├── deploy/
│   └── kubernetes/
│       └── complete-demo.yaml       # Kubernetes manifests
├── infrastructure/
│   ├── terraform/                   # Terraform IaC files
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── vpc.tf
│   └── monitoring/                  # Monitoring configuration
│       ├── prometheus-alerts.yaml
│       └── README.md
├── docs/
│   ├── diagrams/                    # Architecture diagrams
│   ├── screenshots/                 # Dashboard screenshots
│   ├── ARCHITECTURE.md
│   ├── SETUP.md
│   ├── CICD.md
│   └── MONITORING.md
└── README.md
```

9 📸 Screenshots

### Application
![Sock Shop Application](docs/screenshots/application.png)

### Grafana Dashboard
![Grafana Dashboard](docs/screenshots/grafana-dashboard.png)

### GitHub Actions
![CI/CD Pipeline](docs/screenshots/github-actions.png)

10 Lessons Learned

1. **Infrastructure as Code**: Terraform enables reproducible infrastructure
2. **GitOps**: Automated deployments improve reliability
3. **Observability**: Monitoring is crucial for production systems
4. **Cloud-Native**: Kubernetes provides powerful orchestration
5. **Automation**: CI/CD reduces manual errors and deployment time

11 🔧 Troubleshooting

### Common Issues

** Kubernetes crash while running locally**
-Make sure your virtual machine is allocated at least 4 cpu, 8gb ram, and 10gb or more storage.

**Kubernetes or Kubectl crash while getting pods for EKS**
-navigate to main.tf and set node_instance_types to at least [t3.small] and desired_size =3
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
**EKS Cluster Not Accessible:**
```bash
aws eks update-kubeconfig --name dev-sock-shop-eks --region ap-south-1
```

**Pods Not Starting:**
```bash
kubectl get pods -n sock-shop
kubectl describe pod <pod-name> -n sock-shop
kubectl logs <pod-name> -n sock-shop
```

**Load Balancer Not Provisioning:**
```bash
kubectl describe svc front-end -n sock-shop
# Check AWS ELB console for errors
```
                                                                                                         
## Contributing

This is a capstone project, but suggestions are welcome!

## License

This project uses the [Weaveworks Sock Shop](https://github.com/microservices-demo/microservices-demo) demo application, which is licensed under Apache 2.0.

## Author

**Your Name**
- GitHub: [@Dusky88](https://github.com/Dusky88)
- LinkedIn: [Aayush Basnet](www.linkedin.com/in/aayush-basnet-30b874244)

## Acknowledgments

- [Weaveworks Sock Shop](https://microservices-demo.github.io/)
- [Prometheus Community](https://prometheus.io/)
- [Grafana Labs](https://grafana.com/)
- [HashiCorp Terraform](https://www.terraform.io/)

---

**Note**: Remember to replace `YOUR_USERNAME` with your actual GitHub username and update the screenshot paths once you add images.
**Note**: All the EKS configuration has been applied as per the free tier of AWS.
