# Quick Start Guide - Kubernetes Deployment

## One-Step Deployment

Run the automated deployment script:

```bash
./deploy-to-k8s.sh
```

This script will:
1. ✓ Check prerequisites (minikube, kubectl, docker)
2. ✓ Start minikube
3. ✓ Configure Docker for Minikube
4. ✓ Build Docker images (backend and frontend)
5. ✓ Deploy to Kubernetes
6. ✓ Verify all pods are running

## Manual Deployment Steps

### 1. Start Minikube
```bash
minikube start --driver=docker
```

### 2. Configure Docker
```bash
eval $(minikube docker-env)
```

### 3. Build Images
```bash
cd backend && docker build -t backend:latest .
cd ../frontend && docker build -t frontend:latest .
cd ..
```

### 4. Deploy
```bash
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

### 5. Access Application

**With minikube tunnel (Recommended):**
```bash
minikube tunnel
# Then visit: http://localhost:3000
```

**Or use port-forward:**
```bash
kubectl port-forward service/frontend 3000:3000
# Then visit: http://localhost:3000
```

## Common Commands

```bash
# Check pod status
kubectl get pods

# View pod logs
kubectl logs -f deployment/frontend
kubectl logs -f deployment/backend

# Get all services
kubectl get services

# Delete all deployments
kubectl delete -f k8s/

# Stop minikube
minikube stop

# Delete minikube cluster
minikube delete
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│         Minikube Kubernetes Cluster                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │         Frontend Pod (Express)               │  │
│  │  Port: 3000                                  │  │
│  │  Env: API_URL=http://backend:5000           │  │
│  └──────────────────────────────────────────────┘  │
│           │                                        │
│           │ kubernetes DNS                        │
│           v                                        │
│  ┌──────────────────────────────────────────────┐  │
│  │         Backend Pod (Flask)                  │  │
│  │  Port: 5000                                  │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
         │
         │ NodePort (30000)
         v
   Host Machine
   Port 3000
```

## Endpoints

### Frontend
- Home: `http://localhost:3000`
- Get Data: `http://localhost:3000/get-data`
- Greeting: `http://localhost:3000/greet/{name}`

### Backend (Internal)
- Home: `http://backend:5000/`
- Data: `http://backend:5000/api/data`
- Message: `http://backend:5000/api/message/{name}`

## Troubleshooting

**Images not found:**
```bash
eval $(minikube docker-env)
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend
```

**Can't connect to backend:**
- Check backend pod: `kubectl logs deployment/backend`
- Check if service exists: `kubectl get svc backend`

**Minikube network issues:**
```bash
minikube tunnel
# or
minikube ssh
```

## File Structure

```
EC2_app/
├── k8s/                           # Kubernetes manifests
│   ├── backend-deployment.yaml    # Backend deployment
│   ├── backend-service.yaml       # Backend service
│   ├── frontend-deployment.yaml   # Frontend deployment
│   └── frontend-service.yaml      # Frontend service
├── deploy-to-k8s.sh              # Automated deployment script
├── KUBERNETES_DEPLOYMENT.md       # Detailed guide
├── docker-compose.yml             # Docker Compose config
├── backend/
│   ├── app.py                    # Flask app
│   ├── Dockerfile
│   └── requirements.txt
└── frontend/
    ├── server.js                 # Express server
    ├── package.json
    ├── Dockerfile
    ├── public/
    │   ├── app.js
    │   └── styles.css
    └── views/
        └── index.ejs
```
