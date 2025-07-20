@echo off
echo ============================================
echo  Complete Kubernetes Application Stack
echo  Base Apps + Monitoring (Grafana + Prometheus)
echo ============================================
echo.

echo [INFO] Checking VM status...
vagrant status

echo.
echo [INFO] Checking cluster readiness...
vagrant ssh master -c "kubectl get nodes"

echo.
echo [INFO] Deploying base applications...
echo.

echo [INFO] Deploying HTML application...
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/deployment.yaml"
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/service.yaml"

echo.
echo [INFO] Deploying Express application (if exists)...
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/express-deployment.yaml"
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/express-service.yaml"

echo.
echo [INFO] Waiting for applications to be ready...
timeout /t 10 /nobreak >nul

echo.
echo [INFO] Checking application status...
vagrant ssh master -c "kubectl get pods"
vagrant ssh master -c "kubectl get svc"

echo.
echo [INFO] Deploying monitoring stack...
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/deploy-monitoring.yaml"

echo.
echo [INFO] Waiting for monitoring stack to be ready...
timeout /t 15 /nobreak >nul

echo.
echo [INFO] Checking monitoring deployment...
vagrant ssh master -c "kubectl get pods -n monitoring"
vagrant ssh master -c "kubectl get svc -n monitoring"

echo.
echo ============================================
echo  Deployment Complete!
echo ============================================
echo.
echo Application Access URLs:
echo - HTML App: http://192.168.56.10:30080
echo - HTML App: http://192.168.56.11:30080
echo - HTML App: http://192.168.56.12:30080
echo.
echo - Express App: http://192.168.56.10:30000
echo - Express App: http://192.168.56.11:30000
echo - Express App: http://192.168.56.12:30000
echo.
echo Monitoring Access URLs:
echo - Prometheus: http://192.168.56.10:30090
echo - Prometheus: http://192.168.56.11:30090
echo - Prometheus: http://192.168.56.12:30090
echo.
echo - Grafana: http://192.168.56.10:30030
echo - Grafana: http://192.168.56.11:30030
echo - Grafana: http://192.168.56.12:30030
echo.
echo Grafana Login:
echo - Username: admin
echo - Password: admin123
echo.
echo [INFO] To check status anytime:
echo vagrant ssh master -c "kubectl get pods --all-namespaces"
echo.
echo [INFO] To check logs:
echo vagrant ssh master -c "kubectl logs -n monitoring deployment/prometheus"
echo vagrant ssh master -c "kubectl logs -n monitoring deployment/grafana"
echo.
pause