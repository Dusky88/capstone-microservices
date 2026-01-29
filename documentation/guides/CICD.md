# CI/CD Pipeline Documentation

## Overview

This project uses **GitHub Actions** for continuous integration and deployment. The pipeline automatically validates, tests, and deploys changes to the Kubernetes cluster.

## Pipeline Architecture

See [CI/CD Pipeline Diagram](diagrams/cicd-pipeline.md)

## Workflow File

Location: `.github/workflows/ci-cd-pipeline.yaml`

## Pipeline Stages

### 1. Validation Stage
**Trigger**: All pushes and pull requests

**Steps**:
- Checkout code
- Validate Kubernetes YAML manifests
- Parse and verify syntax

**Duration**: ~5 seconds

### 2. Staging Deployment
**Trigger**: Pull requests only

**Steps**:
1. Configure AWS credentials
2. Update kubeconfig for EKS cluster
3. Apply Kubernetes manifests
4. Wait for rollout status (5min timeout)
5. Display application URL

**Duration**: ~1-2 minutes

**Purpose**: Test changes before merging to main

### 3. Production Deployment
**Trigger**: Merge to main branch

**Steps**:
1. Configure AWS credentials
2. Update kubeconfig
3. Deploy to production namespace
4. Wait for all services to stabilize
5. Verify deployment health
6. Display URLs

**Duration**: ~2-3 minutes

**Environment**: Production

## Workflow Configuration

### Environment Variables
```yaml
AWS_REGION: ap-south-1
EKS_CLUSTER_NAME: dev-sock-shop-eks
```

### Required Secrets
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

## Deployment Flow
```
Developer → Feature Branch → Pull Request → Staging Deploy → Code Review → Merge → Production Deploy
```

## Key Features

 **Automated Validation** - Every commit is validated  
 **Staging Environment** - Test before production  
 **Zero-Downtime Deployment** - Kubernetes rolling updates  
 **Rollback Capability** - Via kubectl rollout undo  
 **Monitoring Integration** - Prometheus alerts on failures

## Usage

### Creating a Pull Request
```bash
git checkout -b feature/my-feature
# Make changes
git add .
git commit -m "feat: Add new feature"
git push origin feature/my-feature
# Create PR on GitHub
```

The pipeline automatically:
- Validates manifests
- Deploys to staging
- Reports status on PR

### Deploying to Production
```bash
# Merge PR on GitHub
# Pipeline automatically deploys to production
```

### Manual Trigger
Go to GitHub → Actions → Select workflow → Run workflow

## Monitoring Pipeline

### View Logs
1. Go to GitHub repository
2. Click **Actions** tab
3. Select workflow run
4. Click on job to view logs

### Check Deployment Status
```bash
# Check pods
kubectl get pods -n sock-shop

# Check rollout status
kubectl rollout status deployment/front-end -n sock-shop

# View events
kubectl get events -n sock-shop
```

## Troubleshooting

### Deployment Fails
```bash
# Check pod status
kubectl describe pod <pod-name> -n sock-shop

# View logs
kubectl logs <pod-name> -n sock-shop

# Rollback
kubectl rollout undo deployment/front-end -n sock-shop
```

### AWS Authentication Fails
- Verify GitHub secrets are set correctly
- Check IAM permissions
- Verify AWS region matches

### Timeout Errors
- Increase timeout in workflow (default: 5min)
- Check cluster capacity
- Review resource requests/limits

## Best Practices

1. **Always create PRs** - Don't push directly to main
2. **Review staging deployment** - Test before merging
3. **Monitor after deployment** - Check Grafana dashboards
4. **Keep manifests in sync** - Update YAML files for any manual changes

## Future Enhancements

- [ ] Add automated tests
- [ ] Implement blue-green deployment
- [ ] Add performance testing
- [ ] Integrate Slack notifications
- [ ] Add deployment approval gates
