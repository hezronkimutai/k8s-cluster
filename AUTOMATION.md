# Kubernetes Cluster Automation Scripts

This directory contains automation scripts to set up your Kubernetes cluster automatically, eliminating the need for manual step-by-step configuration.

## 📁 Available Scripts

### [`setup-k8s-cluster.sh`](setup-k8s-cluster.sh) - Linux/macOS
- **Platform**: Linux, macOS, WSL
- **Requirements**: Bash shell
- **Features**: Colored output, comprehensive error handling, progress indicators

### [`setup-k8s-cluster.bat`](setup-k8s-cluster.bat) - Windows
- **Platform**: Windows (Command Prompt, PowerShell)
- **Requirements**: Windows Command Line
- **Features**: Error handling, progress indicators, pause on completion

## 🚀 Quick Start

### Linux/macOS/WSL
```bash
# Make script executable (already done)
chmod +x setup-k8s-cluster.sh

# Run the automation script
./setup-k8s-cluster.sh
```

### Windows
```cmd
# Run from Command Prompt or PowerShell
setup-k8s-cluster.bat
```

## 📋 What the Scripts Do

Both scripts automate the entire cluster setup process described in the documentation:

### 1. **Prerequisites Check**
- ✅ Verifies Vagrant installation
- ✅ Verifies VirtualBox installation
- ✅ Exits gracefully with helpful messages if missing

### 2. **VM Provisioning**
- 🚀 Runs [`vagrant up`](Vagrantfile:1) to start all 3 VMs
- 🖥️ Creates master node (192.168.56.10)
- 🖥️ Creates worker1 node (192.168.56.11)
- 🖥️ Creates worker2 node (192.168.56.12)

### 3. **Kubernetes Installation (All Nodes)**
- 📦 Adds Kubernetes GPG key and repository
- 📦 Installs [`kubelet`](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/), [`kubeadm`](https://kubernetes.io/docs/reference/setup-tools/kubeadm/), [`kubectl`](https://kubernetes.io/docs/reference/kubectl/)
- 🔒 Marks packages as held to prevent auto-updates
- 🌐 Enables IP forwarding (required for cluster networking)

### 4. **Master Node Initialization**
- 🎯 Runs [`kubeadm init`](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/) with proper CIDR and API server address
- ⚙️ Configures [`kubectl`](https://kubernetes.io/docs/reference/kubectl/) for the vagrant user
- 🕸️ Installs Calico CNI plugin for pod networking

### 5. **Worker Node Joining**
- 🔑 Generates join command from master
- 🤝 Joins both worker nodes to the cluster automatically
- ✅ Verifies successful joining

### 6. **Cluster Verification**
- 🧪 Displays cluster nodes status
- 🧪 Shows all running pods across namespaces
- 📊 Confirms cluster is ready for workloads

## 🎯 Expected Output

### Successful Completion
```bash
======================================
   Kubernetes Cluster Setup Script   
======================================

[INFO] Checking prerequisites...
[SUCCESS] Prerequisites check passed
[INFO] Starting Vagrant VMs...
[SUCCESS] Vagrant VMs started successfully
[INFO] Installing Kubernetes on all nodes...
[INFO] Installing Kubernetes on master...
[SUCCESS] Kubernetes installed successfully on master
[INFO] Installing Kubernetes on worker1...
[SUCCESS] Kubernetes installed successfully on worker1
[INFO] Installing Kubernetes on worker2...
[SUCCESS] Kubernetes installed successfully on worker2
[INFO] Initializing Kubernetes master...
[SUCCESS] Kubernetes master initialized successfully
[INFO] Getting join command from master...
[INFO] Join command retrieved: kubeadm join 192.168.56.10:6443 --token ...
[INFO] Joining worker1 to the cluster...
[SUCCESS] worker1 joined the cluster successfully
[INFO] Joining worker2 to the cluster...
[SUCCESS] worker2 joined the cluster successfully
[INFO] Verifying cluster status...
[SUCCESS] Cluster verification completed
[SUCCESS] Kubernetes cluster setup completed!

[INFO] Cluster Information:
  - Master Node: 192.168.56.10
  - Worker Node 1: 192.168.56.11
  - Worker Node 2: 192.168.56.12

[INFO] To access the cluster:
  vagrant ssh master
  kubectl get nodes

[INFO] To deploy applications, you can access the frontend at:
  http://192.168.56.10:30080 (after deploying your apps)

[INFO] Useful commands:
  vagrant status           # Check VM status
  vagrant halt            # Stop all VMs
  vagrant destroy -f      # Destroy all VMs

[SUCCESS] Setup completed successfully!
```

## 🛠️ Manual Steps Automated

The scripts replace these manual steps from the documentation:

| Manual Step | Automated Action |
|-------------|------------------|
| [`vagrant up`](README.md:80) | ✅ Automatic VM startup |
| SSH to each node for K8s installation | ✅ Automated via [`vagrant ssh`](README.md:82) |
| [`kubeadm init`](README.md:145) on master | ✅ Automated with proper parameters |
| [`kubectl`](README.md:148) configuration | ✅ Automated user setup |
| [Calico CNI](README.md:109) installation | ✅ Automated network setup |
| [`kubeadm join`](README.md:197) on workers | ✅ Automated token generation and joining |
| [IP forwarding](README.md:129) setup | ✅ Automated on all nodes |

## 🔧 Troubleshooting

### Common Issues

#### Prerequisites Missing
```bash
[ERROR] Vagrant is not installed. Please install Vagrant first.
[INFO] Visit: https://www.vagrantup.com/downloads
```
**Solution**: Install the missing software and run the script again.

#### VM Startup Failures
```bash
[ERROR] Failed to start Vagrant VMs
```
**Solution**: 
- Check VirtualBox is running
- Ensure Hyper-V is disabled on Windows
- Verify sufficient system resources (8+ GB RAM)

#### Network/Firewall Issues
```bash
[ERROR] Failed to install Kubernetes on <node>
```
**Solution**: 
- Check internet connectivity
- Verify firewall allows outbound HTTPS
- Retry the script

### Recovery Commands

#### Clean Restart
```bash
# Destroy all VMs and start fresh
vagrant destroy -f
./setup-k8s-cluster.sh  # or setup-k8s-cluster.bat
```

#### Check Status
```bash
# Check VM status
vagrant status

# Check cluster from master
vagrant ssh master
kubectl get nodes
kubectl get pods --all-namespaces
```

## 🎉 Next Steps

After successful automation:

1. **Verify Cluster**: [`kubectl get nodes`](README.md:223) should show all 3 nodes as Ready
2. **Deploy Applications**: Use the sample manifests in [`READ.md`](READ.md:152-223)
3. **Access Frontend**: Navigate to `http://192.168.56.10:30080` after deployment

## 📚 Reference Documentation

- **Main Setup Guide**: [`README.md`](README.md)
- **Detailed Instructions**: [`READ.md`](READ.md)
- **Vagrant Configuration**: [`Vagrantfile`](Vagrantfile)

The automation scripts implement exactly the same steps described in these documents, just automatically and with better error handling.