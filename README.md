# Kubernetes Cluster with Vagrant

This project sets up a multi-node Kubernetes cluster using Vagrant with one master node and two worker nodes.

## Cluster Architecture

* **Master Node**: `192.168.56.10` (2 GB RAM, 2 CPUs)
* **Worker Node 1**: `192.168.56.11` (2 GB RAM, 2 CPUs)
* **Worker Node 2**: `192.168.56.12` (2 GB RAM, 2 CPUs)

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

## Initialize Kubernetes on Master

```bash
# On master node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.10

# Configure kubectl for vagrant user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply Flannel CNI plugin
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

## Join Worker Nodes

```bash
# Get the join command on the master node
kubeadm token create --print-join-command

# Run the output join command on worker1 and worker2 (with sudo)
```

## Verify Cluster

```bash
kubectl get nodes
```

## Access Frontend

```bash
http://192.168.56.10:30080
```

Use `kubectl get pods`, `kubectl get services`, `kubectl logs` etc. to manage the application.

## Notes

* Use `vagrant destroy -f && vagrant up` for a clean start.
* Ensure your system has at least 8-12 GB RAM.
* This setup is for **local development** purposes only.
