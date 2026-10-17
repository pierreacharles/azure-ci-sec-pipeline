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

data "google_client_config" "connectivity" {
}

output "connected_project_id" {
  description = "Project configured for the authenticated Google provider."
  value       = data.google_client_config.connectivity.project
}
