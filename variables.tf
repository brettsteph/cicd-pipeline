variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}
variable "project_id" {
  description = "The GCP project id"
  type        = string
}
variable "docker_image_name" {
  description = "Docker image name"
  type        = string
}
variable "image_tag" {
  description = "Storage bucket name"
  type        = string
}
variable "github_repository" {
  type = string
}
variable "github_owner" {
  type = string
}
variable "github_branch" {
  type = string
}
