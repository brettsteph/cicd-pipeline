# CICD Pipleline with GCP Cloud Build, Terraform AND GitHub

This configuration is written in Terraform language and is used to automate the setup of cloud resources on Google Cloud Platform (GCP). 

The code block starting with `terraform` specifies the required provider for GCP. In this case, it's the Google provider from HashiCorp that needs to be installed in Terraform.

The next block starting with `provider` specifies the configuration settings for the `google` provider. It sets the credentials file path for GCP, `project_id`, and `region`.

The block starting with `locals` defines an array of API services that we want to enable dynamically later in the code.

The block `resource google_project_service` is used to manage a single API service for a GCP project. It allows us to enable/disable API services for a project using the provided `local.services` list. The `provisioner` blocks allow Terraform to execute arbitrary commands before and after resource creation, respectively.

Following that, there's a block with `data` that retrieves the default service account for our GCP project.

The block starting with `resource google_project_service_identity` is used to retrieve email from Google-managed service account CloudBuild.

The block starting with `resource google_project_iam_member` assigns the Cloud Build service account email as a member for the specified roles. This will give Cloud Build the necessary rights to use Cloud Run.

The block starting with `resource google_artifact_registry_repository` creates a Docker image repository named "my-repository" in the Google Cloud Platform Artifact Registry. 

The last block is used to create a Cloud Build trigger named "hello-python" using the `google_cloudbuild_trigger` resource type. The trigger responds to changes pushed to a specific GitHub repository specified by variables such as github_repository, github_owner, and github_branch. When triggered, this trigger automatically follows the steps specified in a cloudbuild.yaml file to build a Docker container and deploy the application to Cloud Run. The `substitutions` block allows inputs to be passed into the cloud build job as environment variables. 
