# Kubernetes Cluster Project Brief

## Project Overview
This project sets up a multi-node Kubernetes cluster using Vagrant and VirtualBox for local development purposes. It provides an automated way to create a 3-node Kubernetes cluster with proper networking and CNI configuration.

## Core Objectives
1. **Automated K8s Setup**: Provide scripts for automated Kubernetes cluster deployment
2. **Multi-Node Architecture**: Create a realistic cluster with master and worker nodes
3. **Local Development**: Enable local Kubernetes development and testing
4. **Cross-Platform Support**: Support Windows, macOS, and Linux environments

## Project Structure
- **setup-k8s-cluster.bat**: Windows automation script
- **setup-k8s-cluster.sh**: Linux/macOS automation script  
- **Vagrantfile**: VM configuration for cluster nodes
- **README.md**: Comprehensive setup and usage documentation

## Cluster Configuration
- **Master Node**: 192.168.56.10 (2GB RAM, 2 CPUs)
- **Worker Node 1**: 192.168.56.11 (1GB RAM, 1 CPU)
- **Worker Node 2**: 192.168.56.12 (1GB RAM, 1 CPU)
- **OS**: Ubuntu 20.04 LTS (Focal Fossa)
- **Container Runtime**: containerd
- **CNI Plugin**: Calico (in automation script) / Flannel (in manual docs)

## Current Status
- User attempted to run Windows setup script
- Script failed due to missing VirtualBox installation
- Need to resolve prerequisites before cluster setup can proceed