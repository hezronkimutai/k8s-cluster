# Quick Deployment Commands

## ✅ Cluster Status: READY
All system pods are now Running! Your cluster is ready for application deployment.

## Deploy Everything Now

From the master node, run these commands:

```bash
# Deploy the HTML application first
kubectl apply -f /vagrant/k8s-manifests/deployment.yaml
kubectl apply -f /vagrant/k8s-manifests/service.yaml

# Deploy the monitoring stack
kubectl apply -f /vagrant/k8s-manifests/deploy-monitoring.yaml

# Check deployment status
kubectl get pods
kubectl get pods -n monitoring
kubectl get svc
kubectl get svc -n monitoring
```

## Or Use the Windows Script

From your Windows host:

```bash
deploy-complete-stack.bat
```

## Expected Results

After deployment, you should be able to access:

- **HTML App**: http://192.168.56.10:30080
- **Prometheus**: http://192.168.56.10:30090  
- **Grafana**: http://192.168.56.10:30030 (admin/admin123)

## Quick Status Check

```bash
# Check if applications are deployed
vagrant ssh master -c "kubectl get pods"
vagrant ssh master -c "kubectl get svc"

# Check monitoring stack
vagrant ssh master -c "kubectl get pods -n monitoring"
vagrant ssh master -c "kubectl get svc -n monitoring"
```

The "connection refused" error will resolve once the applications are deployed and their services are running.