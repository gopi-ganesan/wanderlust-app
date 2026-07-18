variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "instance_types" {
  description = "The list of instance types for the EKS worker nodes"
  type        = list(string)
}

variable "desired_size" {
  description = "The desired number of worker nodes in the EKS node group"
  type        = number
}

variable "min_size" {
  description = "The minimum number of worker nodes in the EKS node group"
  type        = number
}

variable "max_size" {
  description = "The maximum number of worker nodes in the EKS node group"
  type        = number
}

variable "disk_size" {
  description = "The disk size (in GiB) for the EKS worker nodes"
  type        = number
}

variable "capacity_type" {
  description = "The capacity type for the EKS worker nodes (e.g., 'ON_DEMAND' or 'SPOT')"
  type        = string
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
}