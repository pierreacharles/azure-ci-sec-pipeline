# azure-ci-sec-pipeline
Sourcing ADO Repository to Target Azure CI Security Pipeline

## Source: GitHub workflow YAML files

This repository contains two GitHub Actions workflow files that act as the source layer for automation. Both are designed to trigger an Azure DevOps pipeline in the target environment after code changes are pushed to the main branch.

### 1) .github/workflows/github-trigger-ado.yml (Source)

This workflow is named `GitHub-IAM-Roles` and is intended to authenticate to Azure using a federated service principal before triggering an Azure DevOps pipeline.

Key code behavior:
- `on: push: branches: [main]` means the workflow runs automatically whenever code is pushed to the `main` branch.
- `jobs.build.runs-on: ubuntu-latest` ensures the automation executes in a Linux GitHub-hosted runner.
- `actions/checkout@v4` checks out the repository source code into the runner workspace.
- The workflow then runs `echo "Run tests/build here"`, which is a placeholder step for future build, validation, or test logic.
- A secure `env` block reads the Azure service principal values from GitHub repository secrets:
  - `AZURE_CLIENT_ID`
  - `AZURE_CLIENT_SECRET`
  - `AZURE_TENANT_ID`
- The shell script validates that each secret is present and exits early if any are missing.
- `az login --service-principal` authenticates the GitHub runner to Azure using the provided service principal credentials.
- `az pipelines run --name "AGAPrjCICT-Pipeline" --project "AGA Assurance Collective Prj 1" --org "https://dev.azure.com/DevOpsExpertOrg1"` triggers the target Azure DevOps pipeline in the specified project and organization.

This file is a direct source-to-target bridge: GitHub pushes the code change, GitHub Action authenticates to Azure, and then Azure DevOps pipeline execution is started.

### 2) .github/workflows/github-deploy-ado.yml (Source)

This workflow is named `GitHub Action triggers Azure` and focuses on triggering the Azure DevOps deployment pipeline using the Azure DevOps CLI extension and a personal access token (PAT).

Key code behavior:
- `on:` includes both `push` to `main` and `workflow_dispatch`, so the pipeline can be triggered manually or automatically.
- `jobs.trigger-azure.runs-on: ubuntu-latest` runs the automation in a GitHub-hosted ubuntu environment.
- The `env` block configures:
  - `AZURE_DEVOPS_EXT_PAT` from a GitHub secret
  - `AZURE_DEVOPS_ORG` set to `https://dev.azure.com/DevOpsExpertOrg1`
- The script checks that the PAT secret is defined before proceeding.
- `az extension add --name azure-devops --only-show-errors` installs the Azure DevOps CLI extension required to interact with Azure DevOps pipelines.
- `printf '%s\n' "$AZURE_DEVOPS_EXT_PAT" | az devops login --organization "$AZURE_DEVOPS_ORG"` signs the GitHub runner into Azure DevOps using the PAT.
- `az pipelines run --name "AGA-Prj-Repo-1" --project "AGA Assurance Collective Prj 1" --org "$AZURE_DEVOPS_ORG"` invokes the target Azure DevOps pipeline for the repository project.

This workflow is useful for deployment-style orchestration because it uses a DevOps PAT and can run both on push and on-demand.

## Target: Azure DevOps pipeline

The target is the Azure DevOps project and pipeline environment referenced by both workflows:
- Organization: `https://dev.azure.com/DevOpsExpertOrg1`
- Project: `AGA Assurance Collective Prj 1`
- Pipeline examples triggered by the source workflows:
  - `AGAPrjCICT-Pipeline`
  - `AGA-Prj-Repo-1`

In this architecture, the GitHub repository and YAML workflows are the source of change, while Azure DevOps is the target execution environment for CI/CD automation. The GitHub Action files establish the handoff from GitHub to Azure DevOps, and the Azure DevOps pipelines perform the actual build, validation, deployment, and security pipeline operations.
