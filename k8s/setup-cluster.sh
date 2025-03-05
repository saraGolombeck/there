#!/bin/bash
# Script to set up a Kubernetes cluster with two servers - manager (server1-manager) and worker (server2)

# Delete existing cluster if any
minikube delete

# Start a new cluster with two nodes
echo "Creating a minikube cluster with two nodes..."
minikube start --nodes=2 -p my-cluster

# Assign names to the servers as shown in the example
echo "Setting name for the first server: server1-manager..."
kubectl label nodes my-cluster kubernetes.io/hostname=server1-manager

echo "Setting name for the second server: server2..."
kubectl label nodes my-cluster-m02 kubernetes.io/hostname=server2

# Update and display node status
echo "Displaying nodes and their labels:"
kubectl get nodes --show-labels

echo "The cluster is ready with two servers:"
echo "1. server1-manager - for the database"
echo "2. server2 - for the backend and frontend"
echo "You can now run: kubectl apply -f ."
