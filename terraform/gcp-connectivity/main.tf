terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

variable "project_id" {
  description = "Google Cloud project used for the read-only connectivity check."
  type        = string
}

provider "google" {
  project = var.project_id
}

data "google_project" "connectivity" {
  project_id = var.project_id
}

output "connected_project_id" {
  description = "Project ID returned by the Google Cloud Resource Manager API."
  value       = data.google_project.connectivity.project_id
}
