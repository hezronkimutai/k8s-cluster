# 🧱 Kubernetes Cluster with Vagrant (3-node Local Setup)

This project provisions a local multi-node Kubernetes cluster using **Vagrant** and **VirtualBox**. It includes:

* 🧠 1 Master node
* 💻 2 Worker nodes
* 📦 All nodes run **Ubuntu 20.04**
* 🚀 You'll deploy a sample Express.js backend and static frontend once the cluster is ready

---

## 👩‍💻 System Requirements (Recommended)

* **OS**: Windows 10/11 64-bit
* **CPU**: 4 cores (your i5-1135G7 is fine)
* **RAM**: At least 8–12 GB
* **Storage**: 20+ GB free

---

## 📦 Software Prerequisites

### 1. Install [Vagrant](https://www.vagrantup.com/downloads)

Run the `.msi` installer as Administrator. Reboot your PC after installation.

### 2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

Use the "Windows hosts" version.

### 3. Disable Hyper-V

VirtualBox requires Hyper-V to be off. Run in Administrator Command Prompt:

```powershell
bcdedit /set hypervisorlaunchtype off
```

Restart your system afterward.

---

## ⚙️ Getting Started

### 1. Clone the Repo

```bash
git clone https://github.com/hezronkimutai/k8s-cluster.git
cd k8s-cluster
```

### 2. Launch the Cluster

```bash
vagrant up
```

This provisions 3 Ubuntu VMs and sets up containerd, disables swap, and configures networking.

---

## 🔧 Manual Kubernetes Setup

### On all nodes (master, worker1, worker2):

```bash
vagrant ssh <node-name>

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo tee -a /etc/sysctl.conf <<< 'net.ipv4.ip_forward=1'
sudo sysctl -p
```

---

## 🚀 Initialize Cluster on Master

```bash
vagrant ssh master

sudo kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --apiserver-advertise-address=192.168.56.10

mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## 🌐 Install Calico (CNI Plugin)

Use Calico instead of Flannel:

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
```

> This installs a CNI plugin compatible with the `192.168.0.0/16` CIDR.

---

## 🤝 Join Worker Nodes

On the master node:

```bash
kubeadm token create --print-join-command
```

Copy and run the command on `worker1` and `worker2`:

```bash
vagrant ssh worker1
sudo <paste-join-command>

vagrant ssh worker2
sudo <paste-join-command>
```

---

## ✅ Validate Cluster

```bash
kubectl get nodes
```

All nodes should show `STATUS = Ready`.

---

## 🧪 Deploy Sample App (Express.js + Static Frontend)

### 1. Build & Push Docker Images

Push your backend and frontend Docker images to Docker Hub or similar.

### 2. `express-backend.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: express-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: express
  template:
    metadata:
      labels:
        app: express
    spec:
      containers:
      - name: express
        image: yourdockerhub/express-app:latest
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: express-service
spec:
  selector:
    app: express
  ports:
  - port: 3000
    targetPort: 3000
  type: NodePort
```

### 3. `frontend.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: yourdockerhub/frontend-app:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
```

### 4. Deploy to Cluster

```bash
kubectl apply -f manifests/
```

### 5. Access the App

```text
http://192.168.56.10:30080
```

---

## 🧼 Tear Down

```bash
vagrant destroy -f
```

To rebuild:

```bash
vagrant up
```

---

## ✅ Final Checklist

* [x] Vagrant + VirtualBox installed
* [x] Hyper-V disabled
* [x] VMs running
* [x] Kubernetes initialized
* [x] Calico installed
* [x] App deployed and reachable

---

Happy hacking! 🎉
