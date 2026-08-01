module "vpc" {
  source = "./modules/vpc"

  vpc_name = var.vpc_name

  cidr_block         = var.cidr_block
  private_subnet     = var.private_subnet
  public_subnet      = var.public_subnet
  availability_zones = var.availability_zones
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = merge(var.tags, {
    Project = "DevOps-Project"
  })
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name

  subnet_ids = module.vpc.private_subnet_ids

  instance_types = var.instance_types
  capacity_type  = var.capacity_type

  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size

  disk_size = var.disk_size

  depends_on = [
    module.vpc
  ]
}

module "ecr" {
  source       = "./modules/ecr"
  repositories = var.repositories
}


data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}



provider "kubernetes" {
  alias                  = "eks"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  alias = "eks"

  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "argocd" {
  source = "./modules/argocd"

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  depends_on = [
    module.eks
  ]
}


terraform {
  backend "s3" {
    bucket  = "my-terraform-state-bucket-gopit-1"
    key     = "eks/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}