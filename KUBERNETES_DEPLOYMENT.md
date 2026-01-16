# Kubernetes Deployment with Minikube

This guide walks through deploying the Flask backend and Express frontend application to a local Kubernetes cluster using Minikube.

## Prerequisites

1. **Docker**: Installed and running
2. **Minikube**: Installed on your system
   ```bash
   # Install minikube
   curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube
   ```

3. **kubectl**: Installed on your system
   ```bash
   # Install kubectl
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   ```

## Step 1: Start Minikube

```bash
minikube start --driver=docker
```

This starts a local Kubernetes cluster using Docker as the container driver.

## Step 2: Point Docker to Minikube

Configure Docker CLI to use Minikube's Docker daemon (so images are built directly in Minikube):

```bash
eval $(minikube docker-env)
```

**Note**: Run this command in your terminal before building images. You may need to re-run it in each new terminal session.

## Step 3: Build Docker Images

Navigate to the project directory and build both images:

```bash
# Build backend image
cd backend
docker build -t backend:latest .

# Build frontend image
cd ../frontend
docker build -t frontend:latest .

cd ..
```

Verify the images are built:

```bash
docker images | grep -E 'backend|frontend'
```

## Step 4: Deploy to Kubernetes

Apply the Kubernetes manifests:

```bash
# Create k8s directory if it doesn't exist
mkdir -p k8s

# Apply backend deployment and service
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml

# Apply frontend deployment and service
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

## Step 5: Verify Deployments

Check if pods are running:

```bash
kubectl get pods
```

Check services:

```bash
kubectl get services
```

View detailed deployment information:

```bash
kubectl get deployments
```

Check pod logs:

```bash
# Backend logs
kubectl logs -l app=backend

# Frontend logs
kubectl logs -l app=frontend
```

## Step 6: Access the Application

The frontend is exposed via NodePort on port 30000.

### Option 1: Using Minikube Tunnel (Recommended)

In a separate terminal, run:

```bash
minikube tunnel
```

Then access the application at: **http://localhost:3000**

### Option 2: Using Minikube Service

```bash
minikube service frontend --url
```

This will output a URL. Copy and paste it into your browser.

### Option 3: Port Forwarding

```bash
kubectl port-forward service/frontend 3000:3000
```

Then access: **http://localhost:3000**

## Useful Commands

### Monitor Logs

```bash
# Watch logs in real-time
kubectl logs -f deployment/frontend
kubectl logs -f deployment/backend

# Get logs from specific pod
kubectl logs <pod-name>
```

### Scale Deployments

```bash
# Scale backend to 2 replicas
kubectl scale deployment backend --replicas=2

# Scale frontend to 2 replicas
kubectl scale deployment frontend --replicas=2
```

### Delete Deployments

```bash
# Delete frontend
kubectl delete deployment frontend
kubectl delete service frontend

# Delete backend
kubectl delete deployment backend
kubectl delete service backend
```

### Delete Everything

```bash
kubectl delete -f k8s/
```

### Stop Minikube

```bash
minikube stop
```

### Delete Minikube Cluster

```bash
minikube delete
```

## Troubleshooting

### Image Pull Errors

If you see `ImagePullBackOff` error, ensure:
1. You've run `eval $(minikube docker-env)` before building images
2. Images are built in Minikube: `minikube docker-env` should show Docker connection details

### Connection Refused

If frontend can't connect to backend:
1. Verify backend service is running: `kubectl get svc backend`
2. Check backend pod logs: `kubectl logs -l app=backend`
3. Ensure both pods are in same cluster

### Debugging a Pod

```bash
# Execute into a running pod
kubectl exec -it <pod-name> -- /bin/bash

# For backend
kubectl exec -it deployment/backend -- /bin/bash

# For frontend
kubectl exec -it deployment/frontend -- /bin/sh
```

## Environment Variables

- **Frontend API_URL**: Set to `http://backend:5000` (uses Kubernetes DNS)
- **Backend**: Runs on port 5000
- **Frontend**: Runs on port 3000

## Kubernetes Resources

- **Deployments**: Control how pods are created and managed
- **Services**: Expose pods to other pods and external traffic
- **ClusterIP**: Backend service (internal communication only)
- **NodePort**: Frontend service (exposed to host machine)

## Example Testing

Once the application is running:

```bash
# Test backend API
curl http://localhost:3000/get-data

# Test greeting endpoint
curl http://localhost:3000/greet/Kubernetes
```
