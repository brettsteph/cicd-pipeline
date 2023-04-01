# CICD Pipeline with GCP Cloud Build, Terraform AND GitHub

![GCP CICD](https://user-images.githubusercontent.com/3052677/229312734-565acb47-12b4-4db0-9fe4-90a990eb0d03.png)

This configuration is written in Terraform language and is used to automate the setup of cloud resources on Google Cloud Platform (GCP). 

The code block starting with `terraform` specifies the required provider for GCP. In this case, it's the Google provider from HashiCorp that needs to be installed in Terraform.

![Google Provider](https://user-images.githubusercontent.com/3052677/228669725-96a8a418-4ca1-4a2e-8678-67841743e68e.png)


The next block starting with `provider` specifies the configuration settings for the `google` provider. It sets the credentials file path for GCP, `project_id`, and `region`.

![Configuration settings for google provider](https://user-images.githubusercontent.com/3052677/228670062-8d1866c9-b5b6-44e6-b4df-6b8905ace527.png)


The block starting with `locals` defines an array of API services that we want to enable dynamically later in the code.

![locals array of APIs](https://user-images.githubusercontent.com/3052677/228670343-4807b06e-3c9e-4737-8bd7-2aa3b5662e31.png)


The block `resource google_project_service` is used to manage a single API service for a GCP project. It allows us to enable/disable API services for a project using the provided `local.services` list. The `provisioner` blocks allow Terraform to execute arbitrary commands before and after resource creation, respectively.

![resource google_project_service](https://user-images.githubusercontent.com/3052677/228670659-2eaa78b5-c411-4822-a3bc-df95158d8347.png)


<!-- Following that, there's a block with `data` that retrieves the default service account for our GCP project. -->

The block starting with `resource google_project_service_identity` is used to retrieve email from Google-managed service account CloudBuild.

![resource google_project_service_identity](https://user-images.githubusercontent.com/3052677/228671030-2de2e629-3aae-4bc6-aaf8-3203c49997c7.png)


The block starting with `resource google_project_iam_member` assigns the Cloud Build service account email as a member for the specified roles. This will give Cloud Build the necessary rights to use Cloud Run.

![resource google_project_iam_member](https://user-images.githubusercontent.com/3052677/228671185-22232eaf-b60e-4b45-8195-7f4f2814cb7b.png)


The block starting with `resource google_artifact_registry_repository` creates a Docker image repository named "my-repository" in the Google Cloud Platform Artifact Registry.

![resource google_artifact_registry_repository](https://user-images.githubusercontent.com/3052677/228671316-f78f6235-68d7-4f94-a494-71ae7101cf93.png)


The last block `google_cloudbuild_trigger` resource type is used to create a Cloud Build trigger. The trigger responds to changes pushed to a specific GitHub repository specified by variables such as github_repository, github_owner, and github_branch. When triggered, this trigger automatically follows the steps specified in a cloudbuild.yaml file to build a Docker container and deploy the application to Cloud Run. The `substitutions` block allows inputs to be passed into the cloud build job as environment variables.

![resource google_cloudbuild_trigger](https://user-images.githubusercontent.com/3052677/228671476-d8378791-8bfb-44a4-888a-2acae55a1eac.png)

