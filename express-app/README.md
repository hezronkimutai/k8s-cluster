# Simple Express.js Application

A lightweight Express.js REST API designed for Kubernetes deployment on the cluster's worker nodes.

## Features

- **Health Check Endpoint**: `/health` for Kubernetes liveness and readiness probes
- **Application Info**: `/api/info` provides system and application information
- **Sample Data API**: `/api/users` returns mock user data
- **Welcome Route**: `/` returns basic application information
- **Error Handling**: Proper error responses and 404 handling
- **Security**: Runs as non-root user in container
- **Monitoring**: Built-in health checks and resource limits

## API Endpoints

### `GET /`
Returns welcome message and basic app information.

**Response Example:**
```json
{
  "message": "Welcome to Simple Express.js App!",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "version": "1.0.0",
  "environment": "production",
  "hostname": "express-app-5d7c8b9f-xyz12"
}
```

### `GET /health`
Health check endpoint for Kubernetes probes.

**Response Example:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "uptime": 3600.5,
  "hostname": "express-app-5d7c8b9f-xyz12"
}
```

### `GET /api/info`
Detailed application and system information.

**Response Example:**
```json
{
  "app": "Simple Express.js App",
  "version": "1.0.0",
  "node_version": "v18.17.0",
  "platform": "linux",
  "memory_usage": {
    "rss": 45678592,
    "heapTotal": 20971520,
    "heapUsed": 15728640,
    "external": 1048576
  },
  "hostname": "express-app-5d7c8b9f-xyz12",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### `GET /api/users`
Sample users data endpoint.

**Response Example:**
```json
{
  "users": [
    { "id": 1, "name": "John Doe", "email": "john@example.com" },
    { "id": 2, "name": "Jane Smith", "email": "jane@example.com" },
    { "id": 3, "name": "Bob Johnson", "email": "bob@example.com" }
  ],
  "count": 3,
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## Local Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Start production server
npm start
```

## Docker

```bash
# Build image
docker build -t express-app:latest .

# Run container
docker run -p 3000:3000 express-app:latest
```

## Kubernetes Deployment

The application is automatically deployed as part of the cluster setup process with:

- **2 replicas** for high availability
- **Resource limits**: 128Mi memory, 100m CPU
- **Health checks**: Liveness and readiness probes
- **Node affinity**: Prefers deployment on worker2
- **NodePort service**: Accessible on port 30081 across all nodes

## Access Points

After deployment, the Express.js API is accessible at:
- `http://192.168.56.10:30081` (Master Node)
- `http://192.168.56.11:30081` (Worker Node 1)
- `http://192.168.56.12:30081` (Worker Node 2)

## Environment Variables

- `NODE_ENV`: Set to "production" in Kubernetes deployment
- `PORT`: Application port (default: 3000)

## Security Features

- Runs as non-root user (nodejs:nodejs)
- Minimal Alpine Linux base image
- Health check validation
- Resource limits and requests defined