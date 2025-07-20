# kubectl Setup Guide for Windows Host

## Issue
You're getting connection errors because kubectl on your Windows host is not configured to connect to the Kubernetes cluster running in the Vagrant VMs.

## Solutions

### Option 1: Use kubectl from Master Node (Recommended)

Always SSH into the master node to run kubectl commands:

```bash
# SSH into master node
vagrant ssh master

# Now run kubectl commands
kubectl get nodes
kubectl get pods --all-namespaces
kubectl apply -f /vagrant/k8s-manifests/deploy-monitoring.yaml
```

### Option 2: Configure kubectl on Windows Host

If you want to use kubectl directly from Windows:

#### Step 1: Copy kubeconfig from master node

```bash
# SSH into master and copy the config
vagrant ssh master
sudo cp /etc/kubernetes/admin.conf /vagrant/kubeconfig
sudo chown vagrant:vagrant /vagrant/kubeconfig
exit
```

#### Step 2: Set KUBECONFIG on Windows

```cmd
# In Windows Command Prompt
set KUBECONFIG=C:\Users\Hezron Kimutai\projects\k8s-cluster\kubeconfig

# Or in PowerShell
$env:KUBECONFIG = "C:\Users\Hezron Kimutai\projects\k8s-cluster\kubeconfig"
```

#### Step 3: Update kubeconfig server address

Edit the kubeconfig file and change the server address from `127.0.0.1:6443` to `192.168.56.10:6443`:

```yaml
# In kubeconfig file, change:
server: https://127.0.0.1:6443
# To:
server: https://192.168.56.10:6443
```

### Option 3: Use Updated Deployment Scripts

I'll create updated scripts that automatically SSH into the master node.

## Current Status Check

To check your cluster status properly:

```bash
# Check if VMs are running
vagrant status

# SSH into master node
vagrant ssh master

# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces
```

## Expected Next Steps

1. **SSH into master node**: `vagrant ssh master`
2. **Wait for cluster ready**: Check if all nodes show "Ready"
3. **Deploy applications**: Apply the base application manifests
4. **Deploy monitoring**: Apply the monitoring stack
5. **Access via browser**: Use the NodePort URLs

## Quick Commands Reference

```bash
# Check cluster status
vagrant ssh master -c "kubectl get nodes"

# Check all pods
vagrant ssh master -c "kubectl get pods --all-namespaces"

# Deploy monitoring (from master node)
vagrant ssh master -c "kubectl apply -f /vagrant/k8s-manifests/deploy-monitoring.yaml"

# Check monitoring status
vagrant ssh master -c "kubectl get pods -n monitoring"