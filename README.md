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

## Next Steps

After the cluster is running:

1. **SSH into the master node**: `vagrant ssh master`
2. **Initialize Kubernetes**: Follow Kubernetes installation guides
3. **Join worker nodes**: Use the join token from master
4. **Deploy applications**: Start deploying your Kubernetes workloads

## Resource Requirements

- **Minimum RAM**: 6GB (2GB per node)
- **Recommended RAM**: 12GB (4GB per node)
- **Disk Space**: ~10GB for base boxes + your applications
- **Network**: Private network on 192.168.56.0/24

## License

This project is open source. Vagrant and VirtualBox/VMware have their own licensing terms.