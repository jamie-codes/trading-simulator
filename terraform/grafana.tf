# This file deploys Grafana using the Helm chart.
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  create_namespace = true

  values = [
    file("${path.module}/../monitoring/grafana-values.yaml")
  ]
}