# Kubernetes Cluster with Vagrant

This project sets up a multi-node Kubernetes cluster using Vagrant with one master node and two worker nodes.

## Cluster Architecture

* **Master Node**: `192.168.56.10` (2 GB RAM, 2 CPUs)
* **Worker Node 1**: `192.168.56.11` (1 GB RAM, 1 CPU)
* **Worker Node 2**: `192.168.56.12` (1 GB RAM, 1 CPUs)

All nodes run Ubuntu 20.04 LTS (Focal Fossa) and come pre-configured with containerd and essential Kubernetes prerequisites.

## Prerequisites

### 1. Download and Install Vagrant

#### Windows

1. Visit the [official Vagrant downloads page](https://www.vagrantup.com/downloads)
2. Download the Windows installer (.msi file)
3. Run the installer with administrator privileges
4. Restart your computer after installation

#### macOS

1. Visit the [official Vagrant downloads page](https://www.vagrantup.com/downloads)
2. Download the macOS installer (.dmg file)
3. Mount the DMG and run the installer
4. Alternatively, use Homebrew: `brew install vagrant`

#### Linux (Ubuntu/Debian)

```bash
# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update and install
sudo apt update
sudo apt install vagrant
```

#### Linux (CentOS/RHEL/Fedora)

```bash
# Add HashiCorp repository
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# Install Vagrant
sudo yum install vagrant
```

### 2. Install VirtualBox (Default Provider)

If you're using VirtualBox:

#### Download VirtualBox

1. Visit [VirtualBox downloads page](https://www.virtualbox.org/wiki/Downloads)
2. Download the appropriate version for your OS
3. Install following the standard installation process

#### VirtualBox PATH Configuration

After installation, VirtualBox may not be automatically added to your system PATH. The provided setup scripts ([`setup-k8s-cluster-fixed.bat`](setup-k8s-cluster-fixed.bat) for Windows, [`setup-k8s-cluster.sh`](setup-k8s-cluster.sh) for Linux/macOS) include automatic detection for common VirtualBox installation locations:

**Windows locations checked:**
- System PATH (if available)
- `C:\Program Files\Oracle\VirtualBox\VBoxManage.exe` (default installation)

**Linux/macOS locations checked:**
- System PATH (if available)
- `/usr/bin/vboxmanage` (standard Linux install)
- `/usr/local/bin/vboxmanage` (custom Linux install)
- `/Applications/VirtualBox.app/Contents/MacOS/VBoxManage` (macOS)

If you encounter VirtualBox detection issues, you can manually add VirtualBox to your PATH or use the improved setup scripts that automatically locate VirtualBox installations.

### 3. Disable Hyper-V (for Windows)

Ensure Hyper-V is disabled when using VirtualBox:

```powershell
bcdedit /set hypervisorlaunchtype off
# Reboot your system
```

## Vagrant Commands

### Essential Commands

```bash
vagrant up                  # Start all VMs
vagrant status             # Check VM status
vagrant ssh <node>         # SSH into master/worker1/worker2
vagrant halt               # Stop VMs
vagrant destroy -f         # Destroy all VMs (force)
vagrant reload --provision # Restart VMs and re-run provisioning
```

### Box Management

```bash
vagrant box list
vagrant box update
vagrant box prune
```

## Installing Kubernetes on Each Node

### Run on All Nodes (Master and Workers)

```bash
# Create keyrings directory
sudo mkdir -p /etc/apt/keyrings

# Add the Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

# Update and install components
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

---

## ✅ Enable IP Forwarding (Required)

Kubernetes requires IP forwarding to be enabled. Without this, `kubeadm init` or `kubeadm join` may fail with fatal preflight errors.

Run the following on **all nodes** (master and workers):

```bash
# Temporarily enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# Make it persistent
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

> ⚠️ If you skip this, you may get:
> `[ERROR FileContent--proc-sys-net-ipv4-ip_forward]: contents are not set to 1`

---

## Initialize Kubernetes on Master

```bash
# On master node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.10

# Configure kubectl for vagrant user (on master only)
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply Flannel CNI plugin (required to get nodes to Ready state)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

> 📝 You only need to configure `kubectl` like this on the master node if you plan to run cluster commands from there. Worker nodes do not need this step.

> ✅ If your nodes show `NotReady`, check that the Flannel CNI plugin was applied successfully using:
> `kubectl get pods -n kube-flannel`

---

## ⚠️ Optional: Fix Pause Image Version Warning

You may see this warning during `kubeadm init`:

```
WARNING: detected that the sandbox image "pause:3.8" is inconsistent with kubeadm's expected "pause:3.9"
```

To fix this:

```bash
# Pull correct image
sudo ctr image pull registry.k8s.io/pause:3.9

# Update containerd config
sudo nano /etc/containerd/config.toml

# Find and replace:
sandbox_image = "registry.k8s.io/pause:3.8"
# With:
sandbox_image = "registry.k8s.io/pause:3.9"

# Restart containerd
sudo systemctl restart containerd
```

Then re-run `kubeadm init` if needed.

---

## Join Worker Nodes

```bash
# Get the join command on the master node
kubeadm token create --print-join-command

# Run the output join command on worker1 and worker2 (with sudo)
```

If you get the following error:

```
[ERROR IsPrivilegedUser]: user is not running as root
```

Run the command with `sudo`.

If you get:

```
[ERROR FileContent--proc-sys-net-ipv4-ip_forward]: contents are not set to 1
```

Then make sure IP forwarding is enabled as shown earlier.

---

## Verify Cluster

```bash
kubectl get nodes
```

Nodes should show `Ready` if networking and CNI (Flannel) are working correctly.

---

## Access Frontend

```bash
http://192.168.56.10:30080
```

Use `kubectl get pods`, `kubectl get services`, `kubectl logs` etc. to manage the application.

## Troubleshooting

### VirtualBox Not Found Error

If you encounter the error:
```
[ERROR] VirtualBox is not installed or not in PATH.
```

**Solution:** Use the improved setup scripts that automatically detect VirtualBox:
- **Windows:** Run [`setup-k8s-cluster-fixed.bat`](setup-k8s-cluster-fixed.bat) instead of the original script
- **Linux/macOS:** The [`setup-k8s-cluster.sh`](setup-k8s-cluster.sh) script includes automatic detection

These scripts check multiple common installation locations and will find VirtualBox even if it's not in your system PATH.

**Manual PATH Fix (Alternative):**
If you prefer to add VirtualBox to your PATH manually:

**Windows:**
1. Add `C:\Program Files\Oracle\VirtualBox` to your PATH environment variable
2. Restart your command prompt/PowerShell

**Linux/macOS:**
```bash
# Add to your shell profile (.bashrc, .zshrc, etc.)
export PATH=$PATH:/usr/bin
# or wherever VirtualBox is installed
```

### Vagrant SSH Issues

If `vagrant ssh` fails, try:
```bash
vagrant reload
vagrant provision
```

### Memory Issues

If VMs fail to start due to memory constraints:
- Reduce VM memory allocation in the [`Vagrantfile`](Vagrantfile)
- Ensure your host system has sufficient available RAM

## Monitoring Stack (Grafana + Prometheus)

This cluster includes a complete monitoring stack with Grafana and Prometheus for observability and metrics collection.

### Quick Deployment

Deploy the monitoring stack with the automated script:

```bash
# Windows
deploy-monitoring.bat

# Linux/macOS
chmod +x deploy-monitoring.sh && ./deploy-monitoring.sh
```

### Manual Deployment

Deploy individual components:

```bash
# Deploy monitoring namespace
kubectl apply -f k8s-manifests/monitoring-namespace.yaml

# Deploy Prometheus
kubectl apply -f k8s-manifests/prometheus.yaml

# Deploy Grafana
kubectl apply -f k8s-manifests/grafana.yaml

# Or deploy everything at once
kubectl apply -f k8s-manifests/deploy-monitoring.yaml
```

### Access Monitoring Tools

**Prometheus** (Metrics Collection):
- URL: `http://192.168.56.10:30090`, `http://192.168.56.11:30090`, or `http://192.168.56.12:30090`
- Access Prometheus web UI to view metrics and targets
- Check `/targets` endpoint to see monitored services

**Grafana** (Visualization Dashboard):
- URL: `http://192.168.56.10:30030`, `http://192.168.56.11:30030`, or `http://192.168.56.12:30030`
- **Username:** `admin`
- **Password:** `admin123`
- Pre-configured with Prometheus data source
- Includes kubernetes cluster monitoring dashboard

### Monitored Components

The monitoring stack automatically collects metrics from:

- **Kubernetes API Server** - Control plane metrics
- **Kubernetes Nodes** - Node-level system metrics
- **Kubernetes Pods** - Pod and container metrics
- **HTML App** - Application-specific metrics
- **Express App** - Node.js application metrics
- **Prometheus** - Self-monitoring
- **Grafana** - Dashboard metrics

### Monitoring Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Applications  │───▶│    Prometheus    │───▶│     Grafana     │
│  (HTML/Express) │    │ (Metrics Store)  │    │  (Dashboards)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
    Port 30080              Port 30090              Port 30030
```

### Available Metrics

- **System Metrics**: CPU, Memory, Disk, Network usage
- **Kubernetes Metrics**: Pod status, node readiness, API server health
- **Application Metrics**: HTTP requests, response times, error rates
- **Custom Metrics**: Application-specific business metrics

### Troubleshooting Monitoring

**Check monitoring pods status:**
```bash
kubectl get pods -n monitoring
```

**View Prometheus logs:**
```bash
kubectl logs -n monitoring deployment/prometheus
```

**View Grafana logs:**
```bash
kubectl logs -n monitoring deployment/grafana
```

**Reset Grafana password:**
```bash
kubectl delete pod -n monitoring -l app=grafana
```

**Port forwarding for local access:**
```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus-service 9090:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana-service 3000:3000
```

---

## Automated Setup Scripts

For quick cluster deployment, use the provided automation scripts:

- **[`setup-k8s-cluster-fixed.bat`](setup-k8s-cluster-fixed.bat)** - Windows automation with improved VirtualBox detection
- **[`setup-k8s-cluster.sh`](setup-k8s-cluster.sh)** - Linux/macOS automation with enhanced prerequisite checking

These scripts handle the complete setup process including:
- Prerequisite validation
- VM provisioning
- Kubernetes installation
- Cluster initialization
- CNI network setup
- Application deployment

## Notes

* Use `vagrant destroy -f && vagrant up` for a clean start.
* Ensure your system has at least 8–12 GB RAM.
* This setup is for **local development** purposes only.
