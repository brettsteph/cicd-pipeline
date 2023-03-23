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
  zone        = var.gcp_zone
}

locals {
  image_name = var.image_name
  services = [
    # "sourcerepo.googleapis.com",
    # "cloudbuild.googleapis.com", //Done manually to setup GitHub
    "run.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}

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


# Create Service Account
resource "google_service_account" "cloudbuild_sa" {
  account_id   = "${var.namespace}-service-account"
  display_name = "A service account a User can use"
}

# # Ensure Cloud Build has sufficient rights to use Cloud Run
# resource "google_project_iam_member" "cloudbuild_run_iam" {
#   # depends_on = [google_cloudbuild_trigger.cicd_trigger]
#   # for_each = toset(["roles/run.admin", "roles/iam.serviceAccountUser"])
#   project = var.project_id
#   # role     = each.key
#   role   = "roles/run.admin"
#   member = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
# }


#  ------ PIPELINE ------  #
# Manually setup GitHub as my repo in Codebuild


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
  }

  filename = "cloudbuild.yaml"
}


# # Create a Cloud Run service that deploys the container image
# resource "google_cloud_run_service" "cicd_service" {
#   depends_on = [
#     google_project_service.enabled_service["run.googleapis.com"]
#   ]
#   name     = var.namespace
#   location = var.gcp_region
#   template {
#     spec {
#       containers {
#         image = local.image_name
#         # image = "us-docker.pkg.dev/cloudrun/container/hello"
#         ports {
#           container_port = 8080
#         }
#       }
#     }
#   }
  
# }


# # Give all users the ability to invoke the service
# resource "google_cloud_run_service_iam_member" "allUsers" {
#   service  = google_cloud_run_service.cicd_service.name
#   location = google_cloud_run_service.cicd_service.location
#   role     = "roles/run.invoker"
#   member   = "allUsers"
# }

# # Enable user access to the web service after the pipeline deploys
# # Grants all users the run.invoker role and attach to the Cloud Run service
# data "google_iam_policy" "admin" {
#   binding {
#     role = "roles/run.invoker"
#     members = [
#       "allUsers",
#     ]
#   }
# }
# resource "google_cloud_run_service_iam_policy" "policy" {
#   location    = var.gcp_region
#   project     = var.project_id
#   service     = google_cloud_run_service.cicd_service.name
#   policy_data = data.google_iam_policy.admin.policy_data
# }
