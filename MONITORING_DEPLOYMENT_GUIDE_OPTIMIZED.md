# Kubernetes Monitoring Stack Deployment Guide (Optimized)

## Overview
This guide provides an optimized monitoring stack deployment for Kubernetes clusters with limited resources. The original monitoring configuration was designed for 3-node clusters but has been optimized to work within 2-node cluster constraints.

## Issues Resolved
The original monitoring stack encountered the following issues:
- **Grafana**: `Pending` status due to insufficient memory (required 750Mi, available ~629Mi)
- **Prometheus**: `ImagePullBackOff` due to resource constraints and older image version
- **Missing Worker2**: Only 2 nodes available instead of expected 3-node cluster

## Optimized Configuration

### Resource Requirements (Optimized)

#### Prometheus
- **Requests**: 100m CPU, 200Mi Memory
- **Limits**: 300m CPU, 350Mi Memory
- **Image**: `prom/prometheus:v2.45.0` (more stable)
- **Storage**: EmptyDir (temporary, survives pod restarts)

#### Grafana
- **Requests**: 100m CPU, 300Mi Memory
- **Limits**: 200m CPU, 400Mi Memory
- **Image**: `grafana/grafana:10.2.0`
- **Storage**: EmptyDir (temporary, survives pod restarts)

### Total Resource Usage
- **Combined CPU Requests**: 200m (down from 500m)
- **Combined Memory Requests**: 500Mi (down from 1006Mi)
- **Fits comfortably in worker1**: 885Mi total memory available

## Deployment Instructions

### Quick Deployment
```bash
# Use the optimized deployment script
./deploy-monitoring-optimized.bat
```

### Manual Deployment
```bash
# Create monitoring namespace
kubectl create namespace monitoring

# Deploy optimized Prometheus
kubectl apply -f k8s-manifests/prometheus-optimized.yaml

# Deploy optimized Grafana  
kubectl apply -f k8s-manifests/grafana-optimized.yaml

# Verify deployment
kubectl get pods -n monitoring
kubectl get services -n monitoring
```

### Verify Deployment
```bash
# Check pod status
kubectl get pods -n monitoring

# Expected output:
# NAME                          READY   STATUS    RESTARTS   AGE
# grafana-56f5c4f9bc-kcpqg      1/1     Running   0          5m
# prometheus-7fb87fdfb5-64vwq   1/1     Running   0          5m

# Check services
kubectl get services -n monitoring

# Expected output:
# NAME                 TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
# grafana-service      NodePort   10.xxx.xxx.xxx   <none>        3000:30030/TCP   5m
# prometheus-service   NodePort   10.xxx.xxx.xxx   <none>        9090:30090/TCP   5m
```

## Access Information

### Prometheus
- **URL**: `http://192.168.56.10:30090`
- **Purpose**: Metrics collection, monitoring queries, and alerting
- **Features**: 
  - Kubernetes API server monitoring
  - Node metrics collection
  - Pod auto-discovery via annotations

### Grafana
- **URL**: `http://192.168.56.10:30030`
- **Login**: `admin` / `admin123`
- **Purpose**: Visualization dashboards and monitoring UI
- **Features**:
  - Pre-configured Prometheus data source
  - Automatic dashboard provisioning
  - Custom dashboard creation

## Monitoring Capabilities

### Automatic Discovery
Both Prometheus and Grafana are configured to automatically discover and monitor:
- Kubernetes API server
- Node metrics (CPU, memory, disk, network)
- Pods with Prometheus annotations:
  ```yaml
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
  ```

### Current Monitored Applications
- **HTML App**: Basic web application with metrics endpoint
- **Express App**: Node.js application with Prometheus metrics
- **Kubernetes System**: API server, nodes, and pod health

## Troubleshooting

### Common Issues

#### Pod Stuck in Pending
```bash
# Check node resources
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name> -n monitoring
```

#### ImagePullBackOff
```bash
# Check image availability
kubectl describe pod <pod-name> -n monitoring

# Verify image versions in manifests
```

#### Memory Issues
```bash
# Check current memory usage
kubectl top nodes
kubectl top pods -n monitoring

# Review resource requests/limits in manifests
```

### Resource Monitoring
```bash
# Check resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Monitor resource allocation
kubectl describe nodes
```

## Configuration Files

### Optimized Manifests
- **`k8s-manifests/prometheus-optimized.yaml`**: Optimized Prometheus deployment
- **`k8s-manifests/grafana-optimized.yaml`**: Optimized Grafana deployment
- **`deploy-monitoring-optimized.bat`**: Automated deployment script

### Original Manifests (Reference)
- **`k8s-manifests/prometheus.yaml`**: Original Prometheus (high resource usage)
- **`k8s-manifests/grafana.yaml`**: Original Grafana (high resource usage)
- **`deploy-monitoring.bat`**: Original deployment script

## Performance Considerations

### Optimizations Applied
1. **Reduced memory requests** to fit 2-node cluster constraints
2. **Lower CPU limits** for better resource sharing
3. **Stable image versions** to avoid pull issues
4. **EmptyDir storage** for simplicity and reliability
5. **Optimized Prometheus configuration** with essential scrape jobs only

### Trade-offs
- **Temporary storage**: Data doesn't persist across pod deletions
- **Limited retention**: 200h metric retention (configurable)
- **Reduced performance**: Lower resource limits may impact query performance
- **No high availability**: Single replica deployments

## Next Steps

### Add Worker2 Node (Recommended)
To deploy the full 3-node cluster and use original high-resource configurations:
```bash
# Check Vagrantfile for worker2 configuration
vagrant up worker2
vagrant ssh master -c "kubeadm token create --print-join-command"
# Run join command on worker2
```

### Enable Persistent Storage
For production use, consider adding persistent volumes:
```yaml
# Example PVC for Prometheus
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-storage
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 10Gi
```

### Add More Monitoring
- **Alertmanager**: For alert handling and notifications
- **Node Exporter**: For detailed node metrics
- **Custom Dashboards**: Application-specific monitoring panels