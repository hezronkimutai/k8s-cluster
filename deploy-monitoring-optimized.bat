@echo off
echo ========================================
echo   Kubernetes Monitoring Stack Deployment
echo   (Optimized for Limited Resources)
echo ========================================
echo.

echo [INFO] Checking if monitoring namespace exists...
vagrant ssh master -c "kubectl get namespace monitoring" >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Creating monitoring namespace...
    vagrant ssh master -c "kubectl create namespace monitoring"
) else (
    echo [INFO] Monitoring namespace already exists
)

echo.
echo [INFO] Deploying optimized Prometheus...
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/prometheus-optimized.yaml"

echo.
echo [INFO] Deploying optimized Grafana...
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/grafana-optimized.yaml"

echo.
echo [INFO] Waiting for pods to start...
timeout /t 30 /nobreak >nul

echo.
echo [INFO] Checking deployment status...
vagrant ssh master -c "kubectl get pods -n monitoring"

echo.
echo [INFO] Checking services...
vagrant ssh master -c "kubectl get services -n monitoring"

echo.
echo ========================================
echo   Monitoring Stack Deployment Complete
echo ========================================
echo.
echo Access Points:
echo - Prometheus: http://192.168.56.10:30090
echo - Grafana:    http://192.168.56.10:30030
echo   Login: admin / admin123
echo.
echo Resource Usage (Optimized):
echo - Prometheus: 100m CPU, 200Mi Memory (limits: 300m CPU, 350Mi Memory)
echo - Grafana:    100m CPU, 300Mi Memory (limits: 200m CPU, 400Mi Memory)
echo.
echo Note: This optimized version uses reduced resource requirements
echo       to fit within the constraints of a 2-node cluster setup.
echo.
pause