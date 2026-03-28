#!/bin/zsh

# ==============================================================================
# Script: quarantine-run.sh
# Purpose: Pulls, scans, and conditionally executes container images.
# ==============================================================================

IMAGE_NAME=$1
AUDIT_DIR="$HOME/.quarantine_audit"

# Ensure audit log directory exists
mkdir -p "$AUDIT_DIR"

if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: ./quarantine-run.sh <image_name:tag>"
    exit 1
fi

echo "[*] Validating Registry and Pulling Image: $IMAGE_NAME"
docker pull "$IMAGE_NAME"

REPORT_FILE="${AUDIT_DIR}/$(echo $IMAGE_NAME | tr '/:' '_')-report.json"

echo "[*] Engaging Trivy. Scanning for HIGH and CRITICAL vulnerabilities..."
# Run Trivy scan. Exit code 1 if HIGH/CRITICAL vulnerabilities are found.
trivy image \
    --severity HIGH,CRITICAL \
    --exit-code 1 \
    --format json \
    --output "$REPORT_FILE" \
    --quiet \
    "$IMAGE_NAME"

SCAN_EXIT_CODE=$?

if [ $SCAN_EXIT_CODE -ne 0 ]; then
    echo "\n[!] ALERT: Security Threshold Breached."
    echo "[!] Image $IMAGE_NAME contains HIGH/CRITICAL vulnerabilities."
    echo "[!] Action: QUARANTINED. Execution blocked."
    echo "[!] Audit log saved to: $REPORT_FILE"
    
    # Enforce quarantine by forcibly removing the image from the local cache
    docker rmi -f "$IMAGE_NAME" >/dev/null 2>&1
    
    exit 1
else
    echo "\n[+] Security Scan Passed. No critical vulnerabilities detected."
    echo "[*] Promoting to Runtime..."
    
    # Execute the container (can be modified to pass custom args)
    docker run -it --rm "$IMAGE_NAME"
fi
