# This file deploys Elasticsearch, Fluentd, and Kibana using Helm.

# Deploy Elasticsearch
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  namespace  = "logging"
  create_namespace = true

  set {
    name  = "replicas"
    value = "1"  # Using 1 replica for the free tier
  }

  set {
    name  = "minimumMasterNodes"
    value = "1"
  }
}

# Deploy Fluentd
resource "helm_release" "fluentd" {
  name       = "fluentd"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluentd"
  namespace  = "logging"
  create_namespace = true

  set {
    name  = "elasticsearch.host"
    value = "elasticsearch-master"  # Points to the Elasticsearch service
  }

  set {
    name  = "elasticsearch.port"
    value = "9200"
  }

  depends_on = [helm_release.elasticsearch]
}

# Deploy Kibana
resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  namespace  = "logging"
  create_namespace = true

  set {
    name  = "elasticsearchHosts"
    value = "http://elasticsearch-master:9200"
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  depends_on = [helm_release.elasticsearch]
}