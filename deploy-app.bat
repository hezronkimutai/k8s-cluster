@echo off
echo ======================================
echo    HTML App Deployment Script
echo ======================================
echo.

echo [INFO] Cleaning up any existing VMs...
vagrant destroy -f 2>nul
if %errorlevel% equ 0 (
    echo [SUCCESS] Existing VMs destroyed
) else (
    echo [INFO] No existing VMs found to destroy
)

echo [INFO] Pruning Vagrant global state...
vagrant global-status --prune >nul 2>&1
echo [SUCCESS] Vagrant cleanup completed
echo.

echo [INFO] Deploying HTML application to Kubernetes cluster...

echo [INFO] Applying deployment manifest...
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/deployment.yaml"

echo [INFO] Applying service manifest...
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/service.yaml"

echo [INFO] Waiting for pods to be ready...
vagrant ssh master -c "kubectl wait --for=condition=ready pod -l app=html-app --timeout=60s"

echo [INFO] Getting deployment status...
vagrant ssh master -c "kubectl get pods,svc -o wide"

echo.
echo [SUCCESS] HTML application deployed successfully!
echo.
echo [INFO] Access your application at:
echo   http://192.168.56.10:30080  (Master Node)
echo   http://192.168.56.11:30080  (Worker Node)
echo.
echo [INFO] Useful commands:
echo   kubectl get pods              # Check pod status
echo   kubectl logs -l app=html-app  # View application logs
echo   kubectl describe svc html-app-service  # Service details
echo.
pause