#!/bin/bash

# Kubernetes Cluster Setup Script
# This script automates the setup of a 2-node Kubernetes cluster using Vagrant
# Compatible with Linux and macOS systems
# Includes automatic HTML application deployment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Cleanup existing VMs
cleanup_vms() {
    log_info "Cleaning up any existing VMs..."
    vagrant destroy -f
    log_success "Cleanup completed"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command_exists vagrant; then
        log_error "Vagrant is not installed. Please install Vagrant first."
        log_info "Visit: https://www.vagrantup.com/downloads"
        exit 1
    fi
    
    if ! command_exists vboxmanage; then
        log_error "VirtualBox is not installed. Please install VirtualBox first."
        log_info "Visit: https://www.virtualbox.org/wiki/Downloads"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Start Vagrant VMs
start_vagrant_vms() {
    log_info "Starting Vagrant VMs..."
    if ! vagrant up; then
        log_error "Failed to start Vagrant VMs"
        exit 1
    fi
    log_success "Vagrant VMs started successfully"
}

# Install Kubernetes on all nodes
install_kubernetes_on_all_nodes() {
    log_info "Installing Kubernetes on all nodes..."
    
    for node in master worker1; do
        log_info "Installing Kubernetes on $node..."
        
        vagrant ssh $node -c '
            # Create keyrings directory
            sudo mkdir -p /etc/apt/keyrings
            
            # Add Kubernetes GPG key
            curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
              sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
            
            # Add Kubernetes repository
            echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
              sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
            
            # Update and install Kubernetes components
            sudo apt-get update
            sudo apt-get install -y kubelet kubeadm kubectl
            sudo apt-mark hold kubelet kubeadm kubectl
            
            # Enable IP forwarding
            sudo sysctl -w net.ipv4.ip_forward=1
            echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
        '
        
        if [ $? -eq 0 ]; then
            log_success "Kubernetes installed successfully on $node"
        else
            log_error "Failed to install Kubernetes on $node"
            exit 1
        fi
    done
}

# Initialize Kubernetes master
initialize_master() {
    log_info "Initializing Kubernetes master..."
    
    vagrant ssh master -c '
        # Initialize Kubernetes cluster
        sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.56.10
        
        # Configure kubectl for vagrant user
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
        
        # Install Calico CNI plugin
        kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
    '
    
    if [ $? -eq 0 ]; then
        log_success "Kubernetes master initialized successfully"
    else
        log_error "Failed to initialize Kubernetes master"
        exit 1
    fi
}

# Get join command and join worker nodes
join_worker_nodes() {
    log_info "Getting join command from master..."
    
    # Get join command from master
    JOIN_COMMAND=$(vagrant ssh master -c 'kubeadm token create --print-join-command' 2>/dev/null | tail -1)
    
    if [ -z "$JOIN_COMMAND" ]; then
        log_error "Failed to get join command from master"
        exit 1
    fi
    
    log_info "Join command retrieved: $JOIN_COMMAND"
    
    # Join worker nodes
    for worker in worker1; do
        log_info "Joining $worker to the cluster..."
        
        vagrant ssh $worker -c "sudo $JOIN_COMMAND"
        
        if [ $? -eq 0 ]; then
            log_success "$worker joined the cluster successfully"
        else
            log_error "Failed to join $worker to the cluster"
            exit 1
        fi
    done
}

# Verify cluster status
verify_cluster() {
    log_info "Verifying cluster status..."
    
    # Wait a bit for nodes to be ready
    sleep 30
    
    vagrant ssh master -c '
        echo "Cluster nodes:"
        kubectl get nodes
        echo ""
        echo "Cluster pods:"
        kubectl get pods --all-namespaces
    '
    
    log_success "Cluster verification completed"
}

# Deploy HTML application
deploy_html_app() {
    log_info "Deploying HTML application..."
    
    # Deploy the application
    vagrant ssh master -c 'kubectl apply -f /vagrant/k8s-manifests/deployment.yaml'
    if [ $? -ne 0 ]; then
        log_error "Failed to deploy HTML application"
        exit 1
    fi
    
    # Deploy the service
    vagrant ssh master -c 'kubectl apply -f /vagrant/k8s-manifests/service.yaml'
    if [ $? -ne 0 ]; then
        log_error "Failed to create HTML service"
        exit 1
    fi
    
    # Wait for pods to be ready
    log_info "Waiting for HTML app pods to be ready..."
    vagrant ssh master -c 'kubectl wait --for=condition=ready pod -l app=html-app --timeout=120s'
    
    log_success "HTML application deployed successfully!"
}

# Display final status
display_final_status() {
    log_info "Final cluster status:"
    vagrant ssh master -c 'kubectl get pods,svc -o wide'
    echo ""
}

# Display access information
display_access_info() {
    log_success "========================================="
    log_success "Complete setup finished successfully!"
    log_success "========================================="
    echo ""
    log_info "Cluster Information:"
    echo "  - Master Node: 192.168.56.10"
    echo "  - Worker Node: 192.168.56.11"
    echo ""
    log_info "Access your HTML application at:"
    echo "  http://192.168.56.10:30080  (Master Node)"
    echo "  http://192.168.56.11:30080  (Worker Node)"
    echo ""
    log_info "To access the cluster:"
    echo "  vagrant ssh master"
    echo "  kubectl get nodes"
    echo ""
    log_info "Useful commands:"
    echo "  vagrant status           # Check VM status"
    echo "  vagrant halt            # Stop all VMs"
    echo "  vagrant destroy -f      # Destroy all VMs"
}

# Main execution
main() {
    echo "======================================"
    echo "   Kubernetes Cluster Setup Script   "
    echo "======================================"
    echo ""
    
    cleanup_vms
    check_prerequisites
    start_vagrant_vms
    install_kubernetes_on_all_nodes
    initialize_master
    join_worker_nodes
    verify_cluster
    deploy_html_app
    display_final_status
    display_access_info
    
    log_success "Setup completed successfully!"
}

# Run main function
main "$@"