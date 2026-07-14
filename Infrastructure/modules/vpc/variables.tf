
variable "private_subnet" {
  description = "List of CIDR blocks for private subnets."
    type        = list(string)
}

variable "public_subnet" {
  description = "List of CIDR blocks for public subnets."
    type        = list(string)
}

variable "single_nat_gateway" {
  description = "Whether to create a single NAT Gateway for all private subnets (true) or one per public subnet (false)."
  type        = bool
  default     = true
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "availability_zones" { # This variable is added to allow distribution of subnets across multiple AZs
  description = "List of availability zones to distribute subnets across."
  type        = list(string) 
}

variable "vpc_name" {
  description = "Name tag for the VPC and related resources."
  type        = string
}


variable "cluster_name" {
  description = "Name of the Kubernetes cluster for tagging purposes."
  type        = string
  default     = "eks-cluster"
}


variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
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