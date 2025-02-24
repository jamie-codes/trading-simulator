# This file deploys Prometheus using the Helm chart.

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true

  values = [
    file("${path.module}/../monitoring/prometheus-values.yaml")
  ]
}