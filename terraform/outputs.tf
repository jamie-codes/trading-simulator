output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "grafana_load_balancer_url" {
  value = helm_release.grafana.status.ingress[0].hostname
}

output "kibana_load_balancer_url" {
  value = helm_release.kibana.status.ingress[0].hostname
}