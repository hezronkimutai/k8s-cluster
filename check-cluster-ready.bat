@echo off
echo =======================================
echo  Kubernetes Cluster Readiness Check
echo =======================================
echo.

echo [INFO] Checking VM status first...
vagrant status

echo.
echo [INFO] Checking cluster readiness...
echo.

echo [INFO] Checking node status...
vagrant ssh master -c "kubectl get nodes"

echo.
echo [INFO] Checking system pods...
vagrant ssh master -c "kubectl get pods -n kube-system"

echo.
echo [INFO] Checking if CNI is ready...
vagrant ssh master -c "kubectl get pods -n kube-system -l k8s-app=calico-node"

echo.
echo [INFO] Checking existing applications...
vagrant ssh master -c "kubectl get pods"
vagrant ssh master -c "kubectl get svc"

echo.
echo =======================================
echo  Cluster Status Summary
echo =======================================

echo.
echo [INFO] If all nodes show 'Ready' status and system pods are 'Running':
echo   - Your cluster is ready for application deployment
echo   - You can now run: deploy-monitoring.bat
echo.
echo [INFO] If nodes show 'NotReady' or pods are 'Pending/Init':
echo   - Wait 2-5 more minutes for initialization to complete
echo   - Run this script again to check status
echo.
echo [INFO] Next steps:
echo   1. Wait for cluster to be fully ready
echo   2. Deploy applications: kubectl apply -f k8s-manifests/deployment.yaml
echo   3. Deploy monitoring: deploy-monitoring.bat
echo   4. Access applications and monitoring dashboards
echo.
pause