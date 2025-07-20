@echo off
setlocal enabledelayedexpansion

REM Kubernetes Cluster Setup Script for Windows
REM This script automates the setup of a 3-node Kubernetes cluster using Vagrant
REM Compatible with Windows systems

echo ======================================
echo    Kubernetes Cluster Setup Script   
echo ======================================
echo.

REM Check if Vagrant is installed
echo [INFO] Checking prerequisites...
where vagrant >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Vagrant is not installed or not in PATH.
    echo [INFO] Please install Vagrant from: https://www.vagrantup.com/downloads
    pause
    exit /b 1
)

REM Check if VirtualBox is installed
where vboxmanage >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] VirtualBox is not installed or not in PATH.
    echo [INFO] Please install VirtualBox from: https://www.virtualbox.org/wiki/Downloads
    pause
    exit /b 1
)

echo [SUCCESS] Prerequisites check passed
echo.

REM Start Vagrant VMs
echo [INFO] Starting Vagrant VMs...
vagrant up
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start Vagrant VMs
    pause
    exit /b 1
)
echo [SUCCESS] Vagrant VMs started successfully
echo.

REM Install Kubernetes on all nodes
echo [INFO] Installing Kubernetes on all nodes...

for %%n in (master worker1 worker2) do (
    echo [INFO] Installing Kubernetes on %%n...
    
    vagrant ssh %%n -c "sudo mkdir -p /etc/apt/keyrings && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null && sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl && sudo apt-mark hold kubelet kubeadm kubectl && sudo sysctl -w net.ipv4.ip_forward=1 && echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"
    
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to install Kubernetes on %%n
        pause
        exit /b 1
    )
    echo [SUCCESS] Kubernetes installed successfully on %%n
)
echo.

REM Initialize Kubernetes master
echo [INFO] Initializing Kubernetes master...

vagrant ssh master -c "sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.56.10 && mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config && kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml"

if %errorlevel% neq 0 (
    echo [ERROR] Failed to initialize Kubernetes master
    pause
    exit /b 1
)
echo [SUCCESS] Kubernetes master initialized successfully
echo.

REM Get join command and join worker nodes
echo [INFO] Getting join command from master...

REM Create a temporary file to store the join command
set "tempfile=%temp%\join_command.txt"

vagrant ssh master -c "kubeadm token create --print-join-command" > "%tempfile%" 2>nul

REM Read the join command (get the last line which should contain the actual command)
set "join_command="
for /f "delims=" %%i in (%tempfile%) do set "join_command=%%i"

if "!join_command!"=="" (
    echo [ERROR] Failed to get join command from master
    del "%tempfile%" 2>nul
    pause
    exit /b 1
)

echo [INFO] Join command retrieved
echo.

REM Join worker nodes
for %%w in (worker1 worker2) do (
    echo [INFO] Joining %%w to the cluster...
    
    vagrant ssh %%w -c "sudo !join_command!"
    
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to join %%w to the cluster
        del "%tempfile%" 2>nul
        pause
        exit /b 1
    )
    echo [SUCCESS] %%w joined the cluster successfully
)

REM Clean up temporary file
del "%tempfile%" 2>nul
echo.

REM Verify cluster status
echo [INFO] Verifying cluster status...
echo [INFO] Waiting 30 seconds for nodes to be ready...
timeout /t 30 /nobreak >nul

vagrant ssh master -c "echo 'Cluster nodes:' && kubectl get nodes && echo '' && echo 'Cluster pods:' && kubectl get pods --all-namespaces"

echo.
echo [SUCCESS] Cluster verification completed
echo.

REM Display access information
echo [SUCCESS] Kubernetes cluster setup completed!
echo.
echo [INFO] Cluster Information:
echo   - Master Node: 192.168.56.10
echo   - Worker Node 1: 192.168.56.11
echo   - Worker Node 2: 192.168.56.12
echo.
echo [INFO] To access the cluster:
echo   vagrant ssh master
echo   kubectl get nodes
echo.
echo [INFO] To deploy applications, you can access the frontend at:
echo   http://192.168.56.10:30080 (after deploying your apps)
echo.
echo [INFO] Useful commands:
echo   vagrant status           # Check VM status
echo   vagrant halt            # Stop all VMs
echo   vagrant destroy -f      # Destroy all VMs
echo.
echo [SUCCESS] Setup completed successfully!
echo.
pause