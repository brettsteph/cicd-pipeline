terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.58.0"
    }
  }
}

provider "google" {
  credentials = file("~/.config/gcloud/application_default_credentials.json")
  project     = var.project_id
  region      = var.gcp_region
}

locals {
  services = [
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
    "run.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}

# Allows management of a single API service for a Google Cloud Platform project.
# Dynamically enable project services
resource "google_project_service" "enabled_service" {
  for_each           = toset(local.services)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = true // May be useful in the event that a project is long-lived but the infrastructure running in that project changes frequently
  provisioner "local-exec" {
    command = "sleep 60"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "sleep 15"
  }
}

# # Retrieve default service account for this project in order to enable compute api
# data "google_compute_default_service_account" "default" {
#   project = var.project_id
#   depends_on = [
#     google_project_service.enabled_service
#   ]
# }

# Used to retrieve email from Google-managed service account CloudBuild
resource "google_project_service_identity" "cicd_si" {
  provider = google-beta

  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

# Ensure Cloud Build has sufficient rights to use Cloud Run
# Assign Cloud Build service account email as a member
resource "google_project_iam_member" "cloudbuild_run_iam" {
  for_each = toset(["roles/run.admin", "roles/iam.serviceAccountUser"])
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_project_service_identity.cicd_si.email}"
}


#  ------ PIPELINE TRIGGER------  #
# Manually setup GitHub as my repo in Cloudbuild


# Create Artifact Registry for Docker images
resource "google_artifact_registry_repository" "my_repo" {
  project       = var.project_id
  location      = var.gcp_region
  repository_id = "my-repository"
  description   = "docker images repository"
  format        = "DOCKER"
  depends_on    = [google_project_service.enabled_service["artifactregistry.googleapis.com"]]
}

# Create Cloud Build trigger
resource "google_cloudbuild_trigger" "cicd_trigger" {
  project  = var.project_id
  location = var.gcp_region
  name     = "hello-python"

  github {
    name  = var.github_repository
    owner = var.github_owner
    push {
      branch = var.github_branch
    }
  }

  substitutions = {
    _ARTIFACT_REGISTRY_REPO = google_artifact_registry_repository.my_repo.repository_id
    _ARTIFACT_REGISTRY_URL  = "${var.gcp_region}-docker.pkg.dev"
    _GCP_REGION             = var.gcp_region
    _PROJECT_NAME           = var.project_id
    _DOCKER_IMAGE_IMAGE     = var.docker_image_name
  }

  filename = "cloudbuild.yaml"
}
