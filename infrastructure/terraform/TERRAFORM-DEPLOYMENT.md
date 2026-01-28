# 🚀 Complete Terraform Deployment Guide - Capstone Project

## Step 3: Infrastructure as Code (IaC) with Terraform

---

## 📋 Prerequisites

### 1. Install AWS CLI

```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

### 2. Configure AWS Credentials

```bash
# Configure AWS (you'll need Access Key ID and Secret Access Key)
aws configure

# Enter when prompted:
AWS Access Key ID: YOUR_ACCESS_KEY
AWS Secret Access Key: YOUR_SECRET_KEY
Default region name: ap-south-1
Default output format: json

# Verify configuration
aws sts get-caller-identity
```

### 3. Install Terraform

```bash
cd ~/terraform

# Download Terraform
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip

# Unzip
unzip terraform_1.7.0_linux_amd64.zip

# Move to PATH
sudo mv terraform /usr/local/bin/

# Verify
terraform --version
```

---

## 📁 Project Setup

### 1. Create All Terraform Files

```bash
cd ~/terraform

# Create all the files with the content I provided above:
# - provider.tf
# - variables.tf
# - vpc.tf
# - security-groups.tf
# - ec2.tf
# - rds.tf
# - load-balancer.tf
# - outputs.tf
# - user-data.sh
# - terraform.tfvars
```

### 2. Update terraform.tfvars

```bash
# Edit terraform.tfvars
nano terraform.tfvars

# ⚠️ IMPORTANT: Change the db_password!
# Also update key_name if you have an SSH key pair
```

### 3. Create SSH Key Pair (Optional but Recommended)

```bash
# Create key pair in AWS
aws ec2 create-key-pair \
  --key-name sock-shop-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/sock-shop-key.pem

# Set permissions
chmod 400 ~/.ssh/sock-shop-key.pem

# Update terraform.tfvars
# Change: key_name = "sock-shop-key"
```

---

## 🚀 Deployment Steps

### Step 1: Initialize Terraform

```bash
cd ~/terraform

# Initialize (downloads providers)
terraform init

# Expected output:
# Terraform has been successfully initialized!
```

### Step 2: Validate Configuration

```bash
# Check for syntax errors
terraform validate

# Should return: Success! The configuration is valid.
```

### Step 3: Format Code

```bash
# Format all .tf files
terraform fmt

# This ensures consistent formatting
```

### Step 4: Plan Infrastructure

```bash
# See what will be created
terraform plan

# Review carefully - you should see:
# ✅ VPC and subnets (6 resources)
# ✅ Internet Gateway and NAT Gateways (3 resources)
# ✅ Route tables (4 resources)
# ✅ Security groups (3 resources)
# ✅ EC2 instances (2 resources)
# ✅ EIPs for EC2 (2 resources)
# ✅ RDS database (1 resource)
# ✅ Application Load Balancer (3 resources)
# ✅ IAM roles and policies (several resources)
#
# Total: ~35-40 resources to be created
```

### Step 5: Apply Infrastructure

```bash
# Create the infrastructure
terraform apply

# Review the plan again
# Type 'yes' when prompted

# ⏰ This will take 10-15 minutes
# The RDS instance takes the longest
```

### Step 6: Save Outputs

```bash
# Once complete, save outputs
terraform output > infrastructure-outputs.txt

# View summary
terraform output deployment_summary

# Get specific values
terraform output application_url
terraform output ec2_public_ips
terraform output rds_endpoint
```

---

## 🔍 Verify Infrastructure

### Check AWS Resources

```bash
# Check VPC
aws ec2 describe-vpcs --region ap-south-1

# Check EC2 instances
aws ec2 describe-instances --region ap-south-1

# Check RDS
aws rds describe-db-instances --region ap-south-1

# Check Load Balancer
aws elbv2 describe-load-balancers --region ap-south-1
```

### SSH into EC2 Instances

```bash
# Get public IPs
terraform output ec2_public_ips

# SSH into first node
ssh -i ~/.ssh/sock-shop-key.pem ubuntu@<PUBLIC_IP>

# Check Docker
docker --version

# Check Kubernetes tools
kubeadm version
kubectl version --client
```

---

## 🎯 Post-Deployment: Setup Kubernetes

### Option 1: Initialize Kubernetes Cluster (Master Node)

```bash
# SSH into first EC2 instance (this will be master)
ssh -i ~/.ssh/sock-shop-key.pem ubuntu@<NODE1_PUBLIC_IP>

# Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Setup kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install CNI (Flannel)
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Get join command for worker nodes
kubeadm token create --print-join-command
```

### Option 2: Use K3s (Lightweight, Easier)

```bash
# On first node (master)
curl -sfL https://get.k3s.io | sh -

# Get kubeconfig
sudo cat /var/lib/rancher/k3s/server/node-token

# On second node (worker)
curl -sfL https://get.k3s.io | K3S_URL=https://<MASTER_PRIVATE_IP>:6443 K3S_TOKEN=<TOKEN> sh -

# On master, verify nodes
sudo k3s kubectl get nodes
```

### Deploy Sock Shop Application

```bash
# On master node
kubectl create namespace sock-shop

# Deploy Sock Shop
kubectl apply -n sock-shop -f "https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml?raw=true"

# Watch pods starting
kubectl -n sock-shop get pods -w

# Wait for all pods to be Running (5-10 minutes)
```

### Update Service to Use NodePort 30001

```bash
# The front-end service should already be NodePort 30001
kubectl -n sock-shop get svc front-end

# If not, patch it:
kubectl -n sock-shop patch svc front-end -p '{"spec":{"type":"NodePort","ports":[{"port":80,"nodePort":30001}]}}'
```

---

## 🌐 Access Application

### Get Load Balancer URL

```bash
# From your local machine
cd ~/terraform
terraform output application_url

# Example output:
# http://sock-shop-alb-123456789.ap-south-1.elb.amazonaws.com
```

### Open in Browser

```bash
# The ALB will forward traffic to NodePort 30001 on EC2 instances
# Open the URL in your browser

# You should see the Sock Shop application! 🎉
```

---

## 💰 Cost Estimation (ap-south-1)

| Resource | Type | Monthly Cost (USD) |
|----------|------|-------------------|
| EC2 Instances | 2x t3.medium | ~$60 |
| RDS MySQL | db.t3.micro | ~$15 |
| Application Load Balancer | 1x ALB | ~$18 |
| NAT Gateways | 2x NAT | ~$65 |
| EBS Storage | 60 GB | ~$6 |
| **Total** | | **~$164/month** |

### Cost Optimization Tips

```bash
# 1. Reduce to 1 NAT Gateway (edit vpc.tf)
# 2. Use t3.small instead of t3.medium
# 3. Stop instances when not in use:

# Stop EC2
aws ec2 stop-instances --instance-ids $(terraform output -json ec2_instance_ids | jq -r '.[]')

# Start EC2
aws ec2 start-instances --instance-ids $(terraform output -json ec2_instance_ids | jq -r '.[]')
```

---

## 🧹 Cleanup / Destroy Infrastructure

### Delete Kubernetes Resources First

```bash
# SSH into master node
kubectl delete namespace sock-shop
```

### Destroy Terraform Infrastructure

```bash
cd ~/terraform

# Destroy everything
terraform destroy

# Type 'yes' when prompted

# ⏰ Takes 5-10 minutes
```

### Verify Cleanup

```bash
# Check no resources remain
aws ec2 describe-instances --region ap-south-1
aws rds describe-db-instances --region ap-south-1
aws elbv2 describe-load-balancers --region ap-south-1
```

---

## 🐛 Troubleshooting

### Terraform Errors

```bash
# Error: Invalid credentials
aws configure  # Re-enter credentials

# Error: Resource already exists
terraform import <resource_type>.<resource_name> <resource_id>

# Error: Timeout
terraform apply -parallelism=1  # Slower but more reliable
```

### EC2 Can't SSH

```bash
# Check security group allows SSH
aws ec2 describe-security-groups --group-ids <SG_ID>

# Verify key permissions
chmod 400 ~/.ssh/sock-shop-key.pem

# Check instance is running
aws ec2 describe-instance-status --instance-ids <INSTANCE_ID>
```

### Application Not Accessible

```bash
# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw alb_arn | sed 's/loadbalancer/targetgroup/')

# Check pods are running
kubectl -n sock-shop get pods

# Check NodePort service
kubectl -n sock-shop get svc front-end
```

### RDS Connection Issues

```bash
# Test from EC2 instance
mysql -h <RDS_ENDPOINT> -u admin -p

# Check security group
aws ec2 describe-security-groups --group-ids <RDS_SG_ID>
```

---

## ✅ Verification Checklist

- [ ] AWS credentials configured
- [ ] Terraform installed and initialized
- [ ] All `.tf` files created
- [ ] `terraform.tfvars` updated with secure password
- [ ] `terraform plan` runs successfully
- [ ] `terraform apply` completes without errors
- [ ] All outputs saved
- [ ] Can SSH into EC2 instances
- [ ] Kubernetes cluster initialized
- [ ] Sock Shop deployed
- [ ] Application accessible via ALB URL
- [ ] Database connection working

---

## 📚 Next Steps

After successful deployment:

1. ✅ **Infrastructure is ready**
2. ➡️ **Step 4: CI/CD Pipeline** (GitHub Actions/Jenkins)
3. ➡️ **Step 5: Containerization** (Optimize Dockerfiles)
4. ➡️ **Step 6: Monitoring** (Prometheus + Grafana)
5. ➡️ **Step 7: Documentation** (Architecture diagrams)

---

## 📸 Architecture Diagram

```
                          Internet
                              |
                    [Internet Gateway]
                              |
                  +-----------+-----------+
                  |                       |
         [Public Subnet 1a]      [Public Subnet 1b]
                  |                       |
             [NAT Gateway]           [NAT Gateway]
                  |                       |
         +--------+---------+    +--------+---------+
         |                  |    |                  |
    [Private Subnet 1a] [Private Subnet 1b]
         |                  |    |                  |
    [EC2 Node 1]       [EC2 Node 2]          [RDS MySQL]
    [K8s Master]       [K8s Worker]
         |                  |
    [Sock Shop Pods]   [Sock Shop Pods]
         |                  |
         +--------+---------+
                  |
        [Application Load Balancer]
                  |
            [Public Internet]
```

Good luck with your deployment! 🚀
