# Monitoring Stack Deployment Guide

## Current Cluster Status

Based on your cluster output, the Kubernetes cluster is still initializing. Before deploying the monitoring stack, ensure the cluster is fully ready.

## Prerequisites Check

### 1. Verify Cluster Readiness

```bash
# SSH into the master node
vagrant ssh master

# Check node status (wait for Ready status)
kubectl get nodes
# Expected: All nodes should show "Ready" status

# Check system pods
kubectl get pods -n kube-system
# Expected: All pods should be "Running" or "Completed"
```

### 2. Wait for CNI Network

The Calico network pods are still initializing. Wait for them to be ready:

```bash
# Monitor Calico pods
kubectl get pods -n kube-system -l k8s-app=calico-node

# Wait for all Calico pods to be Running
watch kubectl get pods -n kube-system
```

## Deploy Applications First

Before deploying monitoring, ensure your base applications are running:

```bash
# Deploy the HTML app
kubectl apply -f /vagrant/k8s-manifests/deployment.yaml
kubectl apply -f /vagrant/k8s-manifests/service.yaml

# Deploy the Express app (if available)
kubectl apply -f /vagrant/k8s-manifests/express-deployment.yaml
kubectl apply -f /vagrant/k8s-manifests/express-service.yaml

# Verify applications are running
kubectl get pods
kubectl get svc
```

## Deploy Monitoring Stack

### Option 1: Quick Deployment (Recommended)

```bash
# From Windows host
deploy-monitoring.bat

# Or from master node
vagrant ssh master
kubectl apply -f /vagrant/k8s-manifests/deploy-monitoring.yaml
```

### Option 2: Step-by-Step Deployment

```bash
# SSH into master node
vagrant ssh master

# 1. Create monitoring namespace
kubectl apply -f /vagrant/k8s-manifests/monitoring-namespace.yaml

# 2. Deploy Prometheus
kubectl apply -f /vagrant/k8s-manifests/prometheus.yaml

# 3. Wait for Prometheus to be ready
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=300s

# 4. Deploy Grafana
kubectl apply -f /vagrant/k8s-manifests/grafana.yaml

# 5. Wait for Grafana to be ready
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=300s

# 6. Verify monitoring stack
kubectl get all -n monitoring
```

## Verification Steps

### Check Monitoring Pod Status

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

Expected output:
```
NAME                          READY   STATUS    RESTARTS   AGE
grafana-xxx                   1/1     Running   0          2m
prometheus-xxx                1/1     Running   0          3m

NAME                       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
grafana-service            NodePort   10.x.x.x        <none>        3000:30030/TCP   2m
prometheus-service         NodePort   10.x.x.x        <none>        9090:30090/TCP   3m
```

### Test Access

1. **Prometheus**: http://192.168.56.10:30090
2. **Grafana**: http://192.168.56.10:30030 (admin/admin123)

## Troubleshooting

### If Nodes Remain NotReady

```bash
# Check CNI pods
kubectl get pods -n kube-system -o wide

# Restart CNI if needed
kubectl delete pods -n kube-system -l k8s-app=calico-node

# Check node logs
kubectl describe node master
kubectl describe node worker1
```

### If Monitoring Pods Don't Start

```bash
# Check pod events
kubectl describe pod -n monitoring -l app=prometheus
kubectl describe pod -n monitoring -l app=grafana

# Check resource constraints
kubectl top nodes
kubectl top pods -n monitoring
```

### If Services Are Not Accessible

```bash
# Verify NodePort services
kubectl get svc -n monitoring
kubectl get svc

# Check if ports are listening
vagrant ssh master
sudo netstat -tlnp | grep :30090
sudo netstat -tlnp | grep :30030
```

### Memory Issues

If pods fail due to memory:

```bash
# Reduce resource requests in manifests
# Edit prometheus.yaml and grafana.yaml to use less memory:
# requests:
#   memory: "128Mi"
#   cpu: "100m"
# limits:
#   memory: "256Mi"
#   cpu: "200m"
```

## Complete Deployment Sequence

1. **Wait for cluster to be ready** (all nodes "Ready", all system pods "Running")
2. **Deploy base applications** (HTML app, Express app)
3. **Verify applications work** (check http://192.168.56.10:30080)
4. **Deploy monitoring stack**
5. **Access monitoring tools**

## Expected Timeline

- **Cluster Ready**: 5-10 minutes after setup completes
- **Application Deployment**: 2-3 minutes
- **Monitoring Stack**: 3-5 minutes
- **Total**: 10-18 minutes from cluster creation

## Access URLs Summary

Once everything is deployed and ready:

- **HTML App**: http://192.168.56.10:30080
- **Express App**: http://192.168.56.10:30000 (if deployed)
- **Prometheus**: http://192.168.56.10:30090
- **Grafana**: http://192.168.56.10:30030 (admin/admin123)

All URLs are also accessible via worker node IPs (192.168.56.11, 192.168.56.12).