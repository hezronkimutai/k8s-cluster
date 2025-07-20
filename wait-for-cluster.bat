@echo off
echo ========================================
echo  Waiting for Kubernetes Cluster Ready
echo ========================================
echo.

echo [INFO] Your cluster is initializing. CNI pods are in Init:2/3 status.
echo [INFO] This script will check every 30 seconds until ready.
echo.

:CHECK_LOOP
echo [INFO] Checking cluster status...
vagrant ssh master -c "kubectl get nodes"

echo.
echo [INFO] Checking CNI pods status...
vagrant ssh master -c "kubectl get pods -n kube-system -l k8s-app=calico-node"

echo.
echo [INFO] Checking if all system pods are ready...
vagrant ssh master -c "kubectl get pods -n kube-system --no-headers | grep -v Running | grep -v Completed"

echo.
echo [INFO] Waiting 30 seconds before next check...
echo [INFO] Press Ctrl+C to stop waiting and deploy anyway
timeout /t 30 /nobreak >nul

echo.
echo ========================================
goto CHECK_LOOP

echo.
echo [SUCCESS] Cluster should be ready now!
echo [INFO] Run: deploy-complete-stack.bat
echo.
pause