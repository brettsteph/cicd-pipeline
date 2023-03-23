variable "gcp_region" {
  description = "GCP region"
  type        = string
}
variable "gcp_zone" {
  description = "GCP zone"
  type        = string
}
variable "project_id" {
  description = "The GCP project id"
  type        = string
}
variable "namespace" {
  description = "The namespace for resource naming"
  type        = string
}

variable "gcp_bucket_name" {
  description = "Storage bucket name"
  type        = string
}

variable "image_name" {
  description = "Storage bucket name"
  type        = string
}

variable "image_tag" {
  description = "Storage bucket name"
  type        = string
}

variable "bucket_name" {
  type        = string
  description = "The name of the test log bucket"
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
