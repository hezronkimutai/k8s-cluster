# Network Connectivity Troubleshooting

If you can't access the services at `http://192.168.56.10:30XXX`, try these steps:

## Quick Fixes

### 1. Check if VMs are Running
```bash
vagrant status
```
All VMs should show "running (virtualbox)"

### 2. Test from Inside the Cluster
```bash
# SSH into master node
vagrant ssh master

# Test services locally
curl http://localhost:30080   # Frontend
curl http://localhost:30081   # Backend API
curl http://localhost:30090   # Prometheus
curl http://localhost:30030   # Grafana
```

### 3. Check Network Interface
```bash
# From your host machine
ping 192.168.56.10
```

## Common Issues & Solutions

### Issue: "Connection timed out" or "Connection refused"

**Solution 1: Windows Firewall**
- Open Windows Defender Firewall
- Allow VirtualBox through firewall
- Or temporarily disable firewall for testing

**Solution 2: VirtualBox Network**
```bash
# Restart VMs
vagrant halt
vagrant up
```

**Solution 3: Check VirtualBox Host-Only Network**
- Open VirtualBox Manager
- Go to File → Host Network Manager
- Ensure "vboxnet0" or similar exists with IP range 192.168.56.x

### Issue: Backend returns 404 or empty response

**Solution: Service Port Configuration**
```bash
vagrant ssh master -c "kubectl get service express-app-service -o yaml"
```
Ensure `targetPort: 80` (not 3000)

## Service Endpoints

Once connected, test these endpoints:

### Frontend (Port 30080)
- `http://192.168.56.10:30080/` - Main page

### Backend API (Port 30081)
- `http://192.168.56.10:30081/` - API documentation
- `http://192.168.56.10:30081/get` - Test GET request
- `http://192.168.56.10:30081/status/200` - Health check

### Prometheus (Port 30090)
- `http://192.168.56.10:30090/` - Prometheus UI
- `http://192.168.56.10:30090/targets` - Monitor targets

### Grafana (Port 30030)
- `http://192.168.56.10:30030/` - Grafana dashboards
- Login: admin/admin123

## Network Requirements

- VirtualBox Host-Only Adapter
- IP Range: 192.168.56.0/24
- No proxy blocking local network access
- Windows: VirtualBox allowed through firewall