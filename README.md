# Container Supply Chain Security Pipeline

This project implements a local container security pipeline on macOS using **Colima** and **Trivy**. It establishes a "quarantine" workflow that prevents vulnerable container images from executing locally.

## Features
- **Zero-Trust Logic:** Automatically scans images before they are run.
- **Threshold Enforcement:** Blocks images with HIGH or CRITICAL vulnerabilities.
- **Audit Logging:** Saves detailed JSON reports for every scan.
- **Visual Dashboard:** Generates a Markdown dashboard summarizing all past scans.

