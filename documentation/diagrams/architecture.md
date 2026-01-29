# System Architecture
```mermaid
graph TB
    subgraph "User Access"
        User[End Users]
    end
    
    subgraph "AWS Cloud"
        subgraph "VPC - ap-south-1"
            subgraph "Public Subnets"
                ALB[Application Load Balancer]
                NAT[NAT Gateway]
            end
            
            subgraph "Private Subnets - AZ1 & AZ2"
                subgraph "EKS Cluster - dev-sock-shop-eks"
                    subgraph "sock-shop namespace"
                        FE[front-end]
                        CAT[catalogue]
                        CART[carts]
                        ORD[orders]
                        PAY[payment]
                        SHIP[shipping]
                        USR[user]
                        QM[queue-master]
                        
                        CATDB[(catalogue-db)]
                        CARTDB[(carts-db)]
                        ORDDB[(orders-db)]
                        USRDB[(user-db)]
                        SESSDB[(session-db)]
                        RMQ[RabbitMQ]
                    end
                    
                    subgraph "monitoring namespace"
                        PROM[Prometheus]
                        GRAF[Grafana]
                        AM[Alertmanager]
                    end
                end
                
                WN1[Worker Node 1<br/>t3.medium]
                WN2[Worker Node 2<br/>t3.medium]
                WN3[Worker Node 3<br/>t3.medium]
            end
        end
    end
    
    subgraph "CI/CD"
        GH[GitHub Repository]
        GHA[GitHub Actions]
        DH[Docker Hub]
    end
    
    subgraph "Infrastructure as Code"
        TF[Terraform]
        AWS_API[AWS APIs]
    end
    
    User -->|HTTP| ALB
    ALB -->|Route| FE
    FE --> CAT
    FE --> CART
    FE --> ORD
    FE --> USR
    CAT --> CATDB
    CART --> CARTDB
    ORD --> ORDDB
    USR --> USRDB
    ORD --> PAY
    ORD --> SHIP
    SHIP --> QM
    QM --> RMQ
    
    PROM -.->|Scrape Metrics| FE
    PROM -.->|Scrape Metrics| CAT
    PROM -.->|Scrape Metrics| CART
    GRAF -.->|Query| PROM
    AM -.->|Alerts| PROM
    
    GH -->|Trigger| GHA
    GHA -->|Deploy| FE
    GHA -->|Pull Images| DH
    
    TF -->|Provision| AWS_API
    AWS_API -->|Create| ALB
    AWS_API -->|Create| WN1
    AWS_API -->|Create| WN2
    AWS_API -->|Create| WN3
    
    style FE fill:#e1f5ff
    style PROM fill:#ff9999
    style GRAF fill:#ffcc99
    style TF fill:#99ff99
```

## Key Components

### Infrastructure Layer
- **VPC**: Custom VPC with public and private subnets across 2 AZs
- **EKS Cluster**: Managed Kubernetes cluster (dev-sock-shop-eks)
- **Worker Nodes**: 3x t3.medium instances
- **Load Balancer**: AWS ELB for external access

### Application Layer (sock-shop namespace)
- **Frontend**: User-facing web application
- **Microservices**: catalogue, carts, orders, payment, shipping, user
- **Databases**: MongoDB and MySQL instances
- **Message Queue**: RabbitMQ for async processing

### Monitoring Layer (monitoring namespace)
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and notifications

### CI/CD Pipeline
- **GitHub**: Source code repository
- **GitHub Actions**: Automated deployment pipeline
- **Docker Hub**: Container image registry

### Infrastructure as Code
- **Terraform**: Infrastructure provisioning and management
