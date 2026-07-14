variable "kubernetes_namespace" {
  description = "The Kubernetes namespace where ArgoCD will be deployed."
  type        = string
  default     = "monitoring"

}

variable "values_serice_type" {
  description = "The type of Kubernetes service to create for ArgoCD server."
  type        = string
  default     = "ClusterIP"

}
