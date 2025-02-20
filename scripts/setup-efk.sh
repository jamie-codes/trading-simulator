#!/bin/bash

# Script to set up the EFK Stack using Helm

# Variables
NAMESPACE="logging"
EFK_VALUES_FILE="../logging/fluentd-values.yaml"

echo "Setting up EFK Stack in namespace $NAMESPACE..."

# Add Elasticsearch Helm repository
helm repo add elastic https://helm.elastic.co
helm repo update

# Install Elasticsearch
helm install elasticsearch elastic/elasticsearch \
  --namespace $NAMESPACE \
  --create-namespace

# Install Fluentd
helm install fluentd fluent/fluentd \
  --namespace $NAMESPACE \
  --create-namespace \
  --values $EFK_VALUES_FILE

# Install Kibana
helm install kibana elastic/kibana \
  --namespace $NAMESPACE \
  --create-namespace

echo "EFK Stack setup completed."