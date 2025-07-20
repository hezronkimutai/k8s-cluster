@echo off
echo ========================================
echo   Kubernetes Complete Stack Deployment
echo ========================================
echo.

echo [INFO] Deploying complete application stack...
echo - Frontend HTML app
echo - Backend API service  
echo - Prometheus monitoring
echo - Grafana dashboards

vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/monitoring-namespace.yaml"
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/frontend-app.yaml"
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/backend-app.yaml"
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/prometheus.yaml"
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/grafana.yaml"

echo.
echo [INFO] Waiting for pods to start...
timeout /t 30 /nobreak >nul

echo.
echo [INFO] Checking deployment status...
vagrant ssh master -c "kubectl get pods --all-namespaces"

echo.
echo [INFO] Checking services...
vagrant ssh master -c "kubectl get services --all-namespaces"

echo.
echo ========================================
echo   Deployment Complete
echo ========================================
echo.
echo Access Points:
echo - Frontend:   http://192.168.56.10:30080
echo - Backend:    http://192.168.56.10:30081  
echo - Prometheus: http://192.168.56.10:30090
echo - Grafana:    http://192.168.56.10:30030 (admin/admin123)
echo.
pause