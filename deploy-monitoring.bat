@echo off
echo ====================================
echo  Kubernetes Monitoring Stack Setup
echo  Grafana + Prometheus Deployment
echo ====================================
echo.

echo [INFO] Checking cluster status first...
vagrant ssh master -c "kubectl get nodes"

echo.
echo [INFO] Deploying monitoring stack...
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/deploy-monitoring.yaml"

echo.
echo [INFO] Waiting for deployments to be ready...
timeout /t 15 /nobreak >nul

echo.
echo [INFO] Checking deployment status...
vagrant ssh master -c "kubectl get pods -n monitoring"

echo.
echo [INFO] Checking services...
vagrant ssh master -c "kubectl get svc -n monitoring"

echo.
echo [INFO] Checking all cluster resources...
vagrant ssh master -c "kubectl get all -n monitoring"

echo.
echo ====================================
echo  Monitoring Stack Deployment Complete!
echo ====================================
echo.
echo Access URLs:
echo - Prometheus: http://192.168.56.10:30090
echo - Prometheus: http://192.168.56.11:30090  
echo - Prometheus: http://192.168.56.12:30090
echo.
echo - Grafana: http://192.168.56.10:30030
echo - Grafana: http://192.168.56.11:30030
echo - Grafana: http://192.168.56.12:30030
echo.
echo Default Grafana Login:
echo - Username: admin
echo - Password: admin123
echo.
echo [INFO] To check monitoring status:
echo kubectl get all -n monitoring
echo.
echo [INFO] To view logs:
echo kubectl logs -n monitoring deployment/prometheus
echo kubectl logs -n monitoring deployment/grafana
echo.
pause