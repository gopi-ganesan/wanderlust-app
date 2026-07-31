vpc_name = "eks-vpc"

cidr_block = "10.0.0.0/16"

availability_zones = ["us-east-1a", "us-east-1b"]

private_subnet = ["10.0.1.0/24", "10.0.2.0/24"]

public_subnet = ["10.0.5.0/24", "10.0.6.0/24"]

cluster_name = "eks-cluster"

aws_region = "us-east-1"

repositories = [
    "wanderlust-frontend",
    "wanderlust-backend",
]


instance_types = ["m7i-flex.large"]

desired_size = 2

min_size = 2

max_size = 2

disk_size = 20

capacity_type = "ON_DEMAND"

node_group_name = "worker-nodes"



