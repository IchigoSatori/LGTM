# Container Supply Chain Security Pipeline

This project implements a local container security pipeline on macOS using **Colima** and **Trivy**. It establishes a "quarantine" workflow that prevents vulnerable container images from executing locally.

## Features
- **Zero-Trust Logic:** Automatically scans images before they are run.
- **Threshold Enforcement:** Blocks images with HIGH or CRITICAL vulnerabilities.
- **Audit Logging:** Saves detailed JSON reports for every scan.
- **Visual Dashboard:** Generates a Markdown dashboard summarizing all past scans.

## Directory Structure
- `scripts/`: Implementation scripts.
    - `quarantine-run.sh`: Wrapper for container pulling and execution.
    - `dashboard.sh`: Metrics extraction and dashboard generation.
- `AUDIT_DASHBOARD.md`: Generated summary of security scans.
- `technical_project_brief.md`: Detailed architectural design and business ROI.

## Usage

### Run a container safely
Instead of `docker run`, use:
```zsh
./scripts/quarantine-run.sh <image_name:tag>
```

### Update the dashboard
```zsh
./scripts/dashboard.sh

