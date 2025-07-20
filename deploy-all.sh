#!/bin/bash

echo "========================================"
echo "  Kubernetes Complete Stack Deployment"
echo "========================================"
echo

echo "[INFO] Deploying complete application stack..."
echo "- Frontend HTML app"
echo "- Backend API service"  
echo "- Prometheus monitoring"
echo "- Grafana dashboards"

vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/all-in-one.yaml"

echo
echo "[INFO] Waiting for pods to start..."
sleep 30

echo
echo "[INFO] Checking deployment status..."
vagrant ssh master -c "kubectl get pods --all-namespaces"

echo
echo "[INFO] Checking services..."
vagrant ssh master -c "kubectl get services --all-namespaces"

echo
echo "========================================"
echo "  Deployment Complete"
echo "========================================"
echo
echo "Access Points:"
echo "- Frontend:   http://192.168.56.10:30080"
echo "- Backend:    http://192.168.56.10:30081"
echo "- Prometheus: http://192.168.56.10:30090"
echo "- Grafana:    http://192.168.56.10:30030 (admin/admin123)"
echo
echo "Press any key to continue..."
read -n 1 -s