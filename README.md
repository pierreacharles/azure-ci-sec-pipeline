# Azure CI Security Pipeline

This repository demonstrates a Python application build and container release using Azure Pipelines. The pipeline validates the Python entry points, builds and tests a hardened Docker image, scans it for vulnerabilities, publishes approved image tags to Docker Hub, and mirrors validated source from Azure Repos to this GitHub repository.

The QA, Test, and PRD stages are release-record gates only. They verify and record the same release artifact in each Azure DevOps environment; they do **not** deploy the application to a runtime or Kubernetes cluster.

## Repository layout

| Path | Purpose |
| --- | --- |
| `azure-pipelines.yml` | Main Azure Pipelines CI/CD definition |
| `Dockerfile` | Multi-stage Python 3.11 Alpine image; runtime uses non-root UID/GID `10001` |
| `main.py` | Root-level Python example |
| `src/ado_package/main.py` | Application entry point copied into the container |
| `terraform/gcp-connectivity/` | Read-only Terraform configuration used to check GCP API access |
| `azure-pipelines-*.yml` | Supporting pipeline examples and templates |
| `.github/workflows/` | GitHub Actions workflow definitions |

## Requirements

- Python 3.11 to run and compile the scripts locally.
- Docker to build and run the container locally.
- Terraform 1.9.8 and the Google Terraform provider are installed by the Azure Pipeline GCP connectivity stage.
- For Azure Pipelines, authorized Docker Hub, Snyk, AWS, and GCP Terraform service connections, a GitHub connection, and the `QA`, `Test`, and `PRD` environments. The pipeline expects these connections to be configured in Azure DevOps; credentials must be stored there, never in repository files.

## Run locally

From the repository root:

```bash
python -m compileall -q main.py src/ado_package/main.py
python main.py
python src/ado_package/main.py
```

Build and run the container:

```bash
docker build --build-arg BUILD_VERSION=dev -t agaprj:dev .
docker run --rm agaprj:dev
```

The container runs the `src/ado_package/main.py` entry point as the unprivileged `10001:10001` user.

## CI and release flow

Azure Repos `main` changes start the pipeline. Changes to the GitHub mirror's `main` also trigger validation; those resource-triggered runs do not sync back to GitHub. The pipeline:

1. Compiles and runs both Python entry points, then validates the Docker build context.
2. Independently runs a Terraform-based Google Cloud connectivity check. It authenticates the Google provider through `GCP-Terraform-ADO-Service-Connection` for project `high-electron-275217`; it does not call project APIs or create or change cloud resources.
3. Builds the image, smoke-tests its output and non-root runtime, and generates a CycloneDX SBOM with Trivy.
4. Uses Trivy and Snyk Container security gates. Trivy blocks High and Critical findings that have a fix available; Snyk analyzes the exact CI-built image and uses a High severity threshold.
5. Publishes the CycloneDX SBOM and a `container-release` artifact containing the image archive and release manifest. Only an image that passes the security gates is pushed to Docker Hub, tagged with the Azure build ID and `latest`.
6. Performs a read-only AWS STS identity check and, for qualifying successful Azure Repos `main` builds, synchronizes validated source to this GitHub repository.
7. Records the same release artifact sequentially in the Azure DevOps `QA`, `Test`, and `PRD` environments. These are release records, not runtime deployments.

The published image repository is `pierrecharles441/agaprj-docker-repository-deploys`. The release manifest records the image, build tag, source commit, and build ID.

## Configuration and security

The pipeline uses the Azure DevOps service connections `login.docker.com_pierrecharles441` (Docker Hub), `Snyk-Security-Scan-ADO-Service-Connection` (Snyk), `aws-prod-oidc` (AWS), and `GCP-Terraform-ADO-Service-Connection` (GCP), plus the GitHub connection configured as `pierreacharles`. Configure and authorize these connections and the `QA`, `Test`, and `PRD` environments in Azure DevOps before running the pipeline. Do not add access tokens, passwords, or other credentials to this repository or its pipeline YAML.

The Docker image uses Python 3.11 Alpine, upgrades Alpine packages during the build, and runs as a non-root user. The pipeline publishes the generated SBOM so the contents of a release can be inspected.

## Contributing

Make changes on a feature branch in the canonical Azure Repos repository and open a pull request to `main`. The pipeline mirrors validated changes to GitHub. Keep pipeline behavior and this documentation aligned, especially when changing security gates, service-connection requirements, image publication, or release environments. Never commit secrets.
