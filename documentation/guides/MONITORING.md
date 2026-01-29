# Monitoring Documentation

## Overview

This project uses **Prometheus** for metrics collection and **Grafana** for visualization, providing comprehensive observability into the Kubernetes cluster and application.

## Architecture

### Components

- **Prometheus**: Time-series metrics database
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and notifications
- **Node Exporter**: Host-level metrics (CPU, memory, disk)
- **Kube State Metrics**: Kubernetes object state metrics

### Installation

Installed via Helm using `kube-prometheus-stack`:
```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin123 \
  --create-namespace
```

## Access

### Grafana
```bash
# Get URL
kubectl get svc prometheus-grafana -n monitoring

# Credentials
Username: admin
Password: admin123
```

### Prometheus
```bash
# Get URL
kubectl get svc prometheus-kube-prometheus-prometheus -n monitoring

# Access at: http://<EXTERNAL-IP>:9090
```

## Pre-configured Dashboards

Navigate to: **Dashboards** → **Browse**

### 1. Kubernetes / Compute Resources / Cluster
- Overall cluster CPU/Memory usage
- Pod count and capacity
- Resource requests vs limits

### 2. Kubernetes / Compute Resources / Namespace (Pods)
- Per-namespace metrics
- Pod CPU and Memory usage
- Network I/O

**Usage**: Select `sock-shop` namespace to monitor application

### 3. Kubernetes / Compute Resources / Node
- Node-level resource usage
- Disk and network metrics
- System load

### 4. Node Exporter / Nodes
- Hardware metrics
- CPU, memory, disk details
- Network interfaces

## Screenshots

See [screenshots](screenshots/) folder for examples:
- `grafana-dashboard.png` - Main cluster dashboard
- `prometheus-targets.png` - Prometheus scraping targets

## Configured Alerts

Location: `infrastructure/monitoring/prometheus-alerts.yaml`

### Alert Rules

#### 1. High CPU Usage
- **Condition**: Container CPU > 80% for 5 minutes
- **Severity**: Warning
- **Action**: Review pod resource allocation

#### 2. Pod Down
- **Condition**: Pod unavailable for 1 minute
- **Severity**: Critical
- **Action**: Check pod logs and events

#### 3. High Memory Usage
- **Condition**: Memory usage > 90% of limit for 5 minutes
- **Severity**: Warning
- **Action**: Review memory limits and usage patterns

#### 4. High Pod Restarts
- **Condition**: Restarts detected in 15 minutes
- **Severity**: Warning
- **Action**: Investigate restart cause

## Viewing Alerts

### In Grafana
1. Go to **Alerting** → **Alert Rules**
2. View active alerts and their status
3. Configure notification channels

### In Prometheus
1. Open Prometheus UI
2. Click **Alerts** tab
3. View firing and pending alerts

### In Alertmanager
```bash
# Get Alertmanager URL
kubectl get svc -n monitoring alertmanager-operated

# Access at: http://<IP>:9093
```

## Metrics Collection

### What Prometheus Monitors

#### Cluster Metrics
- Node CPU, memory, disk, network
- Kubernetes API server
- Controller manager
- Scheduler

#### Application Metrics
- Pod CPU and memory usage
- Container restarts
- Network I/O
- Custom application metrics (if instrumented)

#### Storage Metrics
- Persistent volume usage
- Storage class metrics

### Scrape Intervals
- Default: 30 seconds
- Can be adjusted in ServiceMonitor configs

## Custom Metrics

To add monitoring for your services:

### Create ServiceMonitor
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-service
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: my-service
  endpoints:
  - port: metrics
    interval: 30s
```

### Expose /metrics Endpoint
Your service must expose Prometheus metrics at `/metrics`

## Querying Metrics

### Prometheus Query Examples

**CPU Usage**:
```promql
rate(container_cpu_usage_seconds_total{namespace="sock-shop"}[5m])
```

**Memory Usage**:
```promql
container_memory_usage_bytes{namespace="sock-shop"}
```

**Pod Count**:
```promql
count(kube_pod_info{namespace="sock-shop"})
```

**Request Rate**:
```promql
rate(http_requests_total[5m])
```

## Retention and Storage

- **Prometheus retention**: 15 days (default)
- **Storage**: Persistent volume (if configured)
- **Grafana dashboards**: Stored in ConfigMaps

## Troubleshooting

### Metrics Not Showing
```bash
# Check Prometheus targets
# Status → Targets in Prometheus UI

# Check ServiceMonitors
kubectl get servicemonitor -n monitoring

# Check Prometheus logs
kubectl logs -n monitoring prometheus-kube-prometheus-prometheus-0
```

### Grafana Can't Connect
```bash
# Verify Grafana is running
kubectl get pods -n monitoring | grep grafana

# Check Grafana logs
kubectl logs -n monitoring <grafana-pod>

# Verify datasource configuration
# In Grafana: Configuration → Data Sources
```

### Alerts Not Firing
```bash
# Check PrometheusRule
kubectl get prometheusrule -n monitoring

# View Prometheus rules
# In Prometheus UI: Status → Rules

# Check Alertmanager
kubectl logs -n monitoring alertmanager-prometheus-kube-prometheus-alertmanager-0
```

## Best Practices

1. **Set Resource Limits**: Prevent metrics explosion
2. **Create Custom Dashboards**: For your specific needs
3. **Configure Alert Routing**: Email/Slack notifications
4. **Regular Review**: Check dashboards weekly
5. **Adjust Retention**: Based on storage capacity

## Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
