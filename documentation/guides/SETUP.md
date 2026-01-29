# Setup Guide

Complete step-by-step instructions for deploying this project from scratch.

## Prerequisites

### Required Tools
- AWS CLI v2.x
- Terraform v1.0+
- kubectl v1.29+
- Helm v3.x
- Git

### AWS Account Setup
- Active AWS account
- IAM user with admin permissions
- AWS credentials configured locally

## Step 1: Clone Repository
```bash
git clone https://github.com/Dusky88/capstone-microservices.git
cd capstone-microservices
```

## Step 2: Deploy Infrastructure with Terraform
```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply infrastructure
terraform apply -auto-approve
```

**This creates:**
- VPC with public/private subnets
- EKS cluster (dev-sock-shop-eks)
- Node groups (3x t3.medium)
- Security groups
- IAM roles

**Duration**: ~15-20 minutes

## Step 3: Configure kubectl
```bash
# Update kubeconfig
aws eks update-kubeconfig --name dev-sock-shop-eks --region ap-south-1

# Verify connection
kubectl get nodes
```

You should see 3 nodes in Ready state.

## Step 4: Deploy Application
```bash
cd ~/capstone-microservices

# Deploy all microservices
kubectl apply -f deploy/kubernetes/complete-demo.yaml

# Wait for pods to be ready (this may take 5-10 minutes)
kubectl get pods -n sock-shop -w
```

Press Ctrl+C when all pods show Running status (typically 14 pods total).

## Step 5: Expose Application

**Note**: By default, the front-end service is deployed as NodePort. We need to change it to LoadBalancer for external access.
```bash
# Check current service type
kubectl get svc front-end -n sock-shop

# Change service type from NodePort to LoadBalancer
kubectl patch svc front-end -n sock-shop -p '{"spec":{"type":"LoadBalancer"}}'

# Wait for AWS to provision the Elastic Load Balancer (2-3 minutes)
kubectl get svc front-end -n sock-shop -w
```

**Wait until the EXTERNAL-IP changes from `<pending>` to an AWS hostname.**

Press Ctrl+C once you see the hostname, then:
```bash
# Get the application URL
APP_URL=$(kubectl get svc front-end -n sock-shop -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://$APP_URL"
```

**Access this URL in your browser** to see the Sock Shop application running.

### Making LoadBalancer Permanent

To make this change permanent in your deployment manifests:
```bash
# Edit the manifest
nano deploy/kubernetes/complete-demo.yaml

# Find the front-end Service section and change:
# type: NodePort
# to:
# type: LoadBalancer

# Remove the nodePort: 30001 line

# Commit the change
git add deploy/kubernetes/complete-demo.yaml
git commit -m "feat: Change front-end service to LoadBalancer"
git push origin main
```

## Step 6: Install Monitoring
```bash
# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin123 \
  --create-namespace

# Wait for pods (this may take 3-5 minutes)
kubectl get pods -n monitoring -w
```

Press Ctrl+C when all monitoring pods are Running.

## Step 7: Expose Monitoring Services

### Expose Grafana
```bash
# Change Grafana service to LoadBalancer
kubectl patch svc prometheus-grafana -n monitoring -p '{"spec":{"type":"LoadBalancer"}}'

# Wait for Load Balancer (2-3 minutes)
kubectl get svc prometheus-grafana -n monitoring -w
```

Press Ctrl+C when EXTERNAL-IP appears, then:
```bash
# Get Grafana URL
GRAFANA_URL=$(kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Grafana URL: http://$GRAFANA_URL"
echo "Username: admin"
echo "Password: admin123"
```

### Expose Prometheus (Optional)
```bash
# Change Prometheus service to LoadBalancer
kubectl patch svc prometheus-kube-prometheus-prometheus -n monitoring -p '{"spec":{"type":"LoadBalancer"}}'

# Wait for Load Balancer
kubectl get svc prometheus-kube-prometheus-prometheus -n monitoring -w
```

Press Ctrl+C when ready, then:
```bash
# Get Prometheus URL
PROM_URL=$(kubectl get svc prometheus-kube-prometheus-prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Prometheus URL: http://$PROM_URL:9090"
```

## Step 8: Configure Alerts
```bash
cd infrastructure/monitoring

# Apply custom alert rules
kubectl apply -f prometheus-alerts.yaml

# Verify alerts are loaded
kubectl get prometheusrule -n monitoring
```

You should see `sock-shop-alerts` in the list.

## Step 9: Set Up CI/CD

### Configure GitHub Repository

1. **Fork or push this repository to your GitHub account**

2. **Add GitHub Secrets** (Settings → Secrets and variables → Actions):
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

3. **Push changes to trigger the workflow**:
```bash
git add .
git commit -m "chore: Enable CI/CD pipeline"
git push origin main
```

4. **Verify workflow** (GitHub → Actions tab)

## Step 10: Access Your Application

### Application URLs

Get all your access URLs at once:
```bash
echo "=== Application & Monitoring URLs ==="
echo ""
echo "Sock Shop Application:"
echo "  http://$(kubectl get svc front-end -n sock-shop -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo ""
echo "Grafana Dashboard:"
echo "  http://$(kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "  Username: admin | Password: admin123"
echo ""
echo "Prometheus:"
echo "  http://$(kubectl get svc prometheus-kube-prometheus-prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):9090"
echo ""
```

## Verification Checklist

### Infrastructure
```bash
# Verify EKS cluster
aws eks describe-cluster --name dev-sock-shop-eks --region ap-south-1

# Verify nodes
kubectl get nodes
# Should show 3 nodes in Ready state
```

###  Application
```bash
# All pods running
kubectl get pods -n sock-shop
# Should show ~14 pods, all Running

# Service accessible
curl -I http://<SOCK-SHOP-URL>
# Should return HTTP 200
```

###  Monitoring
```bash
# Monitoring pods running
kubectl get pods -n monitoring
# Should show prometheus, grafana, alertmanager pods Running

# Access Grafana
# Login and verify dashboards are visible
# Navigate to Dashboards → Browse → Select any Kubernetes dashboard
```

###  CI/CD
- GitHub → Actions → Verify latest workflow run is successful (green checkmark)
- Make a test commit and verify deployment

## Troubleshooting

### Pods Not Starting
```bash
# Describe the pod to see events
kubectl describe pod <pod-name> -n sock-shop

# Check pod logs
kubectl logs <pod-name> -n sock-shop

# Check resource constraints
kubectl top nodes
kubectl top pods -n sock-shop
```

### LoadBalancer Stuck in Pending
```bash
# Describe the service to see events
kubectl describe svc front-end -n sock-shop

# Check AWS ELB console for errors
# Verify security groups allow traffic
# Ensure subnets are properly tagged for ELB
```

### Cannot Access Application
```bash
# Verify service is LoadBalancer type
kubectl get svc front-end -n sock-shop

# Check ELB health checks in AWS console
# Verify target groups show healthy instances

# Test from within cluster
kubectl run test --rm -it --image=busybox -- sh
wget -O- http://front-end.sock-shop.svc.cluster.local
```

### Terraform Errors
```bash
# If apply fails, review error and fix
# Common issues: IAM permissions, region limits

# To start over:
terraform destroy -auto-approve
terraform apply -auto-approve
```

### Monitoring Not Working
```bash
# Check Prometheus targets
# Open Prometheus UI → Status → Targets
# All targets should show "UP" (green)

# Restart Prometheus if needed
kubectl delete pod -n monitoring prometheus-kube-prometheus-prometheus-0
```

## Important Notes

### Service Type Changes
- **NodePort → LoadBalancer**: Required for external access
- **LoadBalancer costs**: AWS charges for each ELB (~$18/month per LB)
- **Alternative**: Use Ingress controller (more cost-effective for multiple services)

### Resource Costs
- **EKS Control Plane**: ~$0.10/hour (~$73/month)
- **EC2 t3.medium × 3**: ~$0.0416/hour each (~$90/month total)
- **ELB × 3**: ~$0.025/hour each (~$54/month total)
- **Total estimated cost**: ~$217/month

### Production Considerations
- Enable EKS logging (CloudWatch)
- Configure pod autoscaling (HPA)
- Set up backup strategy for persistent data
- Implement network policies
- Configure SSL/TLS certificates

## Cleanup

**⚠️ Warning**: This will delete all resources and cannot be undone!

### Delete Application and Monitoring
```bash
# Delete application
kubectl delete -f deploy/kubernetes/complete-demo.yaml

# Delete monitoring
helm uninstall prometheus -n monitoring

# Delete namespaces
kubectl delete namespace sock-shop
kubectl delete namespace monitoring
```

### Destroy Infrastructure
```bash
cd infrastructure/terraform

# Destroy all AWS resources
terraform destroy -auto-approve
```

**Verify cleanup** in AWS Console:
- EC2 instances terminated
- Load balancers deleted
- VPC and subnets removed

---

## Next Steps

After successful deployment:

1. **Explore Grafana Dashboards**
   - Kubernetes cluster metrics
   - Application performance
   - Resource utilization

2. **Review CI/CD Pipeline**
   - Make a test change
   - Create a PR
   - Watch automated deployment

3. **Configure Alerts**
   - Set up Slack/Email notifications
   - Test alert firing
   - Tune alert thresholds

4. **Optimize Resources**
   - Adjust pod replicas
   - Set resource limits
   - Enable autoscaling

See [MONITORING.md](MONITORING.md) and [CICD.md](CICD.md) for more details.
