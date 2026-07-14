output "repository_urls" {
  value = {
    for repo in aws_ecr_repository.repos-module :
    repo.name => repo.repository_url
  }
}