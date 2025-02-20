#!/bin/bash

# Script to set up Prometheus using Helm

# Variables
NAMESPACE="monitoring"
PROMETHEUS_VALUES_FILE="../monitoring/prometheus-values.yaml"

echo "Setting up Prometheus in namespace $NAMESPACE..."

# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --create-namespace \
  --values $PROMETHEUS_VALUES_FILE

echo "Prometheus setup completed."