#!/bin/bash

# Kubernetes Deployment Script for Minikube
# This script automates the deployment of Flask backend and Express frontend to Minikube

set -e

echo "==================================="
echo "Kubernetes Minikube Deployment"
echo "==================================="

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube is not installed. Please install it first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install it first."
    exit 1
fi

echo "✓ All prerequisites found"

# Start Minikube
echo ""
echo "Starting Minikube..."
if ! minikube status &> /dev/null; then
    minikube start --driver=docker
    echo "✓ Minikube started"
else
    echo "✓ Minikube is already running"
fi

# Point Docker to Minikube
echo ""
echo "Configuring Docker to use Minikube..."
eval $(minikube docker-env)
echo "✓ Docker configured for Minikube"

# Build images
echo ""
echo "Building Docker images..."
echo "  - Building backend image..."
cd backend
docker build -t backend:latest .
cd ..
echo "  ✓ Backend image built"

echo "  - Building frontend image..."
cd frontend
docker build -t frontend:latest .
cd ..
echo "  ✓ Frontend image built"

# Verify images
echo ""
echo "Verifying images..."
if docker images | grep -q "backend.*latest"; then
    echo "  ✓ Backend image found"
fi
if docker images | grep -q "frontend.*latest"; then
    echo "  ✓ Frontend image found"
fi

# Create k8s directory
if [ ! -d "k8s" ]; then
    echo ""
    echo "Creating k8s directory..."
    mkdir -p k8s
    echo "✓ k8s directory created"
fi

# Deploy to Kubernetes
echo ""
echo "Deploying to Kubernetes..."
echo "  - Deploying backend..."
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
echo "  ✓ Backend deployed"

echo "  - Deploying frontend..."
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
echo "  ✓ Frontend deployed"

# Wait for deployments to be ready
echo ""
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend
kubectl wait --for=condition=available --timeout=300s deployment/frontend
echo "✓ All deployments are ready"

# Display status
echo ""
echo "==================================="
echo "Deployment Status"
echo "==================================="
echo ""
echo "Pods:"
kubectl get pods
echo ""
echo "Services:"
kubectl get services
echo ""
echo "Deployments:"
kubectl get deployments

# Get the frontend service URL
echo ""
echo "==================================="
echo "Access Information"
echo "==================================="
echo ""
echo "To access the frontend application:"
echo ""
echo "Option 1 - Using minikube tunnel (recommended):"
echo "  1. In a separate terminal, run: minikube tunnel"
echo "  2. Open browser and go to: http://localhost:3000"
echo ""
echo "Option 2 - Using minikube service:"
echo "  minikube service frontend --url"
echo ""
echo "Option 3 - Port forwarding:"
echo "  kubectl port-forward service/frontend 3000:3000"
echo "  Open browser and go to: http://localhost:3000"
echo ""
echo "To view logs:"
echo "  Frontend: kubectl logs -f deployment/frontend"
echo "  Backend:  kubectl logs -f deployment/backend"
echo ""
echo "==================================="
echo "✓ Deployment Complete!"
echo "==================================="
