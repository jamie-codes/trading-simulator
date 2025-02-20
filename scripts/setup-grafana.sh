#!/bin/bash

# Script to set up Grafana using Helm

# Variables
NAMESPACE="monitoring"
GRAFANA_VALUES_FILE="../monitoring/grafana-values.yaml"

echo "Setting up Grafana in namespace $NAMESPACE..."

# Add Grafana Helm repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Grafana
helm install grafana grafana/grafana \
  --namespace $NAMESPACE \
  --create-namespace \
  --values $GRAFANA_VALUES_FILE

echo "Grafana setup completed."