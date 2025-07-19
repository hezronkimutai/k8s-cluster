# Kubernetes Cluster with Vagrant

This project sets up a multi-node Kubernetes cluster using Vagrant with one master node and two worker nodes.

## Cluster Architecture

- **Master Node**: `192.168.56.10` (2 GB RAM, 2 CPUs)
- **Worker Node 1**: `192.168.56.11` (2 GB RAM, 2 CPUs)
- **Worker Node 2**: `192.168.56.12` (2 GB RAM, 2 CPUs)

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

### 2. Download and Install VMware (Alternative to VirtualBox)

> **Note**: This Vagrantfile is currently configured for VirtualBox, but can be modified for VMware.

#### VMware Workstation Pro (Windows/Linux)
1. Visit [VMware Workstation Pro download page](https://www.vmware.com/products/workstation-pro.html)
2. Purchase and download VMware Workstation Pro
3. Run the installer and follow the setup wizard
4. Enter your license key when prompted

#### VMware Fusion (macOS)
1. Visit [VMware Fusion download page](https://www.vmware.com/products/fusion.html)
2. Purchase and download VMware Fusion
3. Mount the DMG and drag VMware Fusion to Applications
4. Launch and enter your license key

#### VMware Vagrant Plugin
After installing VMware, install the Vagrant VMware plugin:
```bash
vagrant plugin install vagrant-vmware-desktop
```

### 3. VirtualBox (Default Provider)

If you prefer to use VirtualBox (which this project is configured for):

#### Download VirtualBox
1. Visit [VirtualBox downloads page](https://www.virtualbox.org/wiki/Downloads)
2. Download the appropriate version for your OS
3. Install following the standard installation process

## Vagrant Commands

### Essential Commands

#### Start the Cluster
```bash
# Start all nodes
vagrant up

# Start a specific node
vagrant up master
vagrant up worker1
vagrant up worker2
```

#### Check Status
```bash
# Check status of all machines
vagrant status

# Global status (all Vagrant environments)
vagrant global-status
```

#### SSH into Nodes
```bash
# SSH into master node
vagrant ssh master

# SSH into worker nodes
vagrant ssh worker1
vagrant ssh worker2
```

#### Stop and Manage VMs
```bash
# Gracefully stop all VMs
vagrant halt

# Stop a specific VM
vagrant halt master

# Forcefully stop VMs
vagrant halt --force

# Restart VMs
vagrant reload

# Restart with provisioning
vagrant reload --provision
```

#### Destroy and Cleanup
```bash
# Destroy all VMs (WARNING: This deletes all data)
vagrant destroy

# Destroy specific VM
vagrant destroy master

# Destroy without confirmation
vagrant destroy -f
```

### Advanced Commands

#### Provisioning
```bash
# Re-run provisioning on all machines
vagrant provision

# Re-run provisioning on specific machine
vagrant provision master
```

#### Suspend and Resume
```bash
# Suspend all VMs (save state)
vagrant suspend

# Resume suspended VMs
vagrant resume

# Suspend specific VM
vagrant suspend worker1
```

#### Box Management
```bash
# List installed boxes
vagrant box list

# Update boxes
vagrant box update

# Remove unused boxes
vagrant box prune
```

### Useful Workflow Commands

#### Quick Development Cycle
```bash
# Start fresh environment
vagrant destroy -f && vagrant up

# Restart and reprovision
vagrant reload --provision

# Check logs
vagrant ssh master -c "sudo journalctl -u kubelet"
```

#### Resource Monitoring
```bash
# Check VM resource usage
vagrant ssh master -c "htop"
vagrant ssh master -c "free -h"
vagrant ssh master -c "df -h"
```

## Troubleshooting

### Common Issues

#### Port Conflicts
If you encounter port conflicts:
```bash
# Check which ports are in use
vagrant port

# Kill conflicting processes (Windows)
netstat -ano | findstr :8080
taskkill /PID <process_id> /F

# Kill conflicting processes (Linux/macOS)
lsof -ti:8080 | xargs kill -9
```

#### Network Issues
```bash
# Restart networking in VM
vagrant ssh master -c "sudo systemctl restart networking"

# Check network configuration
vagrant ssh master -c "ip addr show"
```

#### Storage Issues
```bash
# Clean up Vagrant boxes
vagrant box prune

# Clean up VirtualBox VMs
VBoxManage list vms
VBoxManage unregistervm <vm-name> --delete
```

### Performance Optimization

#### Increase VM Resources
Modify the [`Vagrantfile`](Vagrantfile) to allocate more resources:
```ruby
vb.memory = 4096  # Increase to 4GB
vb.cpus = 4       # Increase to 4 CPUs
```

#### Enable VirtualBox Features
```ruby
vb.customize ["modifyvm", :id, "--ioapic", "on"]
vb.customize ["modifyvm", :id, "--memory", "2048"]
vb.customize ["modifyvm", :id, "--cpus", "2"]
```

## Switching to VMware Provider

To use VMware instead of VirtualBox, modify the [`Vagrantfile`](Vagrantfile):

```ruby
# Replace the VirtualBox provider block with:
node.vm.provider "vmware_desktop" do |vmware|
  vmware.memory = 2048
  vmware.cpus = 2
  vmware.gui = false
end
```

Then use VMware-specific commands:
```bash
# Start with VMware provider
vagrant up --provider=vmware_desktop

# Check VMware-specific status
vagrant status
```

## Setting Up Kubernetes Cluster for Web Application

After the VMs are running, here's how to set up a complete Kubernetes cluster for a simple HTML frontend with a backend API:

### Step 1: Initialize Kubernetes on Master Node

```bash
# SSH into master node
vagrant ssh master

# Install kubeadm, kubelet, and kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize the cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.56.10

# Set up kubectl for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel network plugin
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

### Step 2: Join Worker Nodes

```bash
# Get the join command from master (run on master)
kubeadm token create --print-join-command

# SSH into each worker node and run the join command
vagrant ssh worker1
# Run the join command with sudo (example):
# sudo kubeadm join 192.168.56.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

vagrant ssh worker2
# Run the same join command with sudo
```

### Step 3: Verify Cluster Setup

```bash
# On master node, check if all nodes are ready
kubectl get nodes

# Should show:
# NAME      STATUS   ROLES           AGE   VERSION
# master    Ready    control-plane   5m    v1.28.x
# worker1   Ready    <none>          3m    v1.28.x
# worker2   Ready    <none>          3m    v1.28.x
```

### Step 4: Deploy Sample Web Application

Create the following Kubernetes manifests for a simple HTML frontend with a Node.js backend:

#### Backend API Deployment (`backend-deployment.yaml`)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  labels:
    app: backend-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend-api
  template:
    metadata:
      labels:
        app: backend-api
    spec:
      containers:
      - name: backend
        image: node:16-alpine
        ports:
        - containerPort: 3000
        command: ["sh", "-c"]
        args:
          - |
            echo 'const express = require("express");
            const cors = require("cors");
            const app = express();
            
            app.use(cors());
            app.use(express.json());
            
            app.get("/api/health", (req, res) => {
              res.json({ status: "healthy", timestamp: new Date().toISOString() });
            });
            
            app.get("/api/data", (req, res) => {
              res.json({
                message: "Hello from Kubernetes Backend!",
                pod: process.env.HOSTNAME,
                data: ["item1", "item2", "item3"]
              });
            });
            
            app.listen(3000, () => {
              console.log("Backend running on port 3000");
            });' > app.js &&
            npm init -y &&
            npm install express cors &&
            node app.js
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend-api
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
  type: ClusterIP
```

#### Frontend Deployment (`frontend-deployment.yaml`)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-web
  labels:
    app: frontend-web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend-web
  template:
    metadata:
      labels:
        app: frontend-web
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: frontend-html
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend-web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
  nodePort: 30080
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-html
data:
  index.html: |
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Kubernetes Web App</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { text-align: center; color: #333; margin-bottom: 30px; }
            .api-data { background: #e8f5e8; padding: 15px; border-radius: 5px; margin: 20px 0; }
            .status { padding: 10px; border-radius: 5px; margin: 10px 0; }
            .healthy { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
            .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
            button { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; margin: 5px; }
            button:hover { background: #0056b3; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚀 Kubernetes Web Application</h1>
                <p>Simple HTML Frontend + Node.js Backend</p>
            </div>
            
            <div id="status" class="status">
                <strong>Status:</strong> <span id="status-text">Checking...</span>
            </div>
            
            <div class="api-data">
                <h3>Backend API Data:</h3>
                <button onclick="fetchData()">Fetch Data from Backend</button>
                <button onclick="checkHealth()">Check Backend Health</button>
                <pre id="api-response">Click "Fetch Data" to load data from the backend API...</pre>
            </div>
            
            <div class="api-data">
                <h3>Cluster Information:</h3>
                <p><strong>Frontend Pods:</strong> Running on multiple worker nodes</p>
                <p><strong>Backend Pods:</strong> Load-balanced across cluster</p>
                <p><strong>Network:</strong> Pod-to-pod communication via Kubernetes services</p>
            </div>
        </div>

        <script>
            const BACKEND_URL = 'http://192.168.56.10:30081'; // NodePort service
            
            async function fetchData() {
                try {
                    document.getElementById('api-response').textContent = 'Loading...';
                    const response = await fetch(`${BACKEND_URL}/api/data`);
                    const data = await response.json();
                    document.getElementById('api-response').textContent = JSON.stringify(data, null, 2);
                    updateStatus('healthy', 'Connected to backend API');
                } catch (error) {
                    document.getElementById('api-response').textContent = `Error: ${error.message}`;
                    updateStatus('error', 'Failed to connect to backend');
                }
            }
            
            async function checkHealth() {
                try {
                    const response = await fetch(`${BACKEND_URL}/api/health`);
                    const data = await response.json();
                    document.getElementById('api-response').textContent = JSON.stringify(data, null, 2);
                    updateStatus('healthy', 'Backend is healthy');
                } catch (error) {
                    updateStatus('error', 'Backend health check failed');
                }
            }
            
            function updateStatus(type, message) {
                const statusEl = document.getElementById('status');
                const statusText = document.getElementById('status-text');
                statusEl.className = `status ${type}`;
                statusText.textContent = message;
            }
            
            // Check initial status
            checkHealth();
        </script>
    </body>
    </html>
```

#### Backend Service with NodePort (`backend-nodeport.yaml`)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-nodeport
spec:
  selector:
    app: backend-api
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
      nodePort: 30081
  type: NodePort
```

### Step 5: Deploy the Application

```bash
# On master node, create the deployment files
cat > backend-deployment.yaml << 'EOF'
# [Copy the backend deployment YAML from above]
EOF

cat > frontend-deployment.yaml << 'EOF'
# [Copy the frontend deployment YAML from above]
EOF

cat > backend-nodeport.yaml << 'EOF'
# [Copy the backend NodePort YAML from above]
EOF

# Deploy all components
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f backend-nodeport.yaml

# Check deployment status
kubectl get pods
kubectl get services
kubectl get deployments
```

### Step 6: Access Your Application

```bash
# Check that all pods are running
kubectl get pods -o wide

# Access the frontend
# Open browser to: http://192.168.56.10:30080
# (or any worker node IP on port 30080)

# Test backend directly
curl http://192.168.56.10:30081/api/health
curl http://192.168.56.10:30081/api/data
```

### Step 7: Scaling and Management

```bash
# Scale backend replicas
kubectl scale deployment backend-api --replicas=3

# Scale frontend replicas
kubectl scale deployment frontend-web --replicas=3

# View logs
kubectl logs -f deployment/backend-api
kubectl logs -f deployment/frontend-web

# Update deployments
kubectl set image deployment/backend-api backend=node:18-alpine
kubectl rollout status deployment/backend-api

# Monitor resources
kubectl top nodes
kubectl top pods
```

### Application Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Browser  │    │   Load Balancer │    │  Ingress (opt)  │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          │ http://192.168.56.10:30080 (Frontend)       │
          └──────────────────────┼──────────────────────┘
                                 │
┌────────────────────────────────┼────────────────────────────────┐
│              Kubernetes Cluster │                                │
│                                 ▼                                │
│  ┌─────────────────┐    ┌─────────────────┐                     │
│  │  Frontend Pods  │    │  Backend Pods   │                     │
│  │   (Nginx HTML)  │    │   (Node.js API) │                     │
│  │   Port 80       │    │   Port 3000     │                     │
│  └─────────┬───────┘    └─────────┬───────┘                     │
│            │                      │                             │
│  ┌─────────▼───────┐    ┌─────────▼───────┐                     │
│  │Frontend Service │    │Backend Service  │                     │
│  │  (NodePort)     │    │  (NodePort)     │                     │
│  │  Port 30080     │    │  Port 30081     │                     │
│  └─────────────────┘    └─────────────────┘                     │
└─────────────────────────────────────────────────────────────────┘
```

This setup provides:
- **High Availability**: Multiple replicas of both frontend and backend
- **Load Balancing**: Kubernetes automatically distributes traffic
- **Service Discovery**: Pods communicate via Kubernetes services
- **Scalability**: Easy to scale up/down with `kubectl scale`
- **Rolling Updates**: Zero-downtime deployments

## Quick Start Summary

1. **Start VMs**: `vagrant up`
2. **Setup Kubernetes**: Follow Step 1-3 above
3. **Deploy App**: Apply the YAML files from Step 4-5
4. **Access**: Open `http://192.168.56.10:30080` in your browser

## Resource Requirements

- **Minimum RAM**: 6GB (2GB per node)
- **Recommended RAM**: 12GB (4GB per node)
- **Disk Space**: ~10GB for base boxes + your applications
- **Network**: Private network on 192.168.56.0/24

## License

This project is open source. Vagrant and VirtualBox/VMware have their own licensing terms.