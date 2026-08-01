variable "vpc_name" {
    description = "Name tag for the VPC and related resources."
    type        = string
    default     = "eks-vpc"
}

variable "cidr_block" {
    description = "The CIDR block for the VPC."
    type        = string
    default = "10.0.0.0/16"
}

variable "availability_zones" { # This variable is added to allow distribution of subnets across multiple AZs
    description = "List of availability zones to distribute subnets across."
    type        = list(string) 
    default = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet" {
    description = "List of CIDR blocks for private subnets."
    type        = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet" {
    description = "List of CIDR blocks for public subnets."
    type        = list(string)
    default = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "enable_nat_gateway" {
    description = "Whether to create NAT Gateways for private subnets."
    type        = bool
    default     = true
}

variable "single_nat_gateway" {
    description = "Whether to create a single NAT Gateway for all private subnets (true) or one per public subnet (false)."
    type        = bool
    default     = true
}

variable "cluster_name" {
    description = "Name of the Kubernetes cluster for tagging purposes."
    type        = string
    default     = "eks-cluster"
}


variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "repositories" {
  description = "List of ECR repository names to create."
  type        = list(string)
  default     = ["app-repo", "db-repo"]
}


variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "eks"
  }
}

variable "private_subnet_tags" {
  description = "Additional tags to apply to private subnets."
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags to apply to public subnets."
  type        = map(string)
  default     = {}
}

#this for eks

variable "instance_types" {
  description = "this useing on ec2 type"
  type = list(string)
}

variable "node_group_name" {
  description = "this using an name for nod group"
  type = string
  
}

variable "max_size" {
  description = "this using an max number of ec2"
  type = number
  
}

variable "min_size" {
  description = "The minimum number of worker nodes in the EKS node group"
  type        = number
}


variable "disk_size" {
  description = "this using an disk number of ec2"
  type = number
  
}


variable "desired_size" {
  description = "this using an disk number of ec2"
  type = number
  
}

variable "capacity_type" {
  type        = string
  description = "ON_DEMAND or SPOT"
}


variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "deploy_k8s_apps" {
  description = "Deploy ArgoCD and Prometheus"
  type        = bool
  default     = false
}