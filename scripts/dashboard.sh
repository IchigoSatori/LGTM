#!/bin/zsh

# ==============================================================================
# Script: dashboard.sh
# Purpose: Generates a Markdown dashboard from Trivy scan reports.
# ==============================================================================

AUDIT_DIR="$HOME/.quarantine_audit"
DASHBOARD_FILE="AUDIT_DASHBOARD.md"

if [ ! -d "$AUDIT_DIR" ]; then
    echo "Error: Audit directory $AUDIT_DIR does not exist."
    exit 1
fi

echo "# Container Security Audit Dashboard" > "$DASHBOARD_FILE"
echo "Generated on: $(date)" >> "$DASHBOARD_FILE"
echo "" >> "$DASHBOARD_FILE"
echo "| Image Name | Scan Date | HIGH | CRITICAL | Status |" >> "$DASHBOARD_FILE"
echo "|------------|-----------|------|----------|--------|" >> "$DASHBOARD_FILE"

for report in "$AUDIT_DIR"/*.json; do
    [ -e "$report" ] || continue
    
    IMAGE=$(jq -r '.Metadata.RepoTags[0] // .Metadata.ImageID' "$report")
    DATE=$(jq -r '.CreatedAt' "$report" | cut -d'T' -f1)
    
    HIGH_COUNT=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' "$report")
    CRITICAL_COUNT=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$report")
    
    if [ "$HIGH_COUNT" -gt 0 ] || [ "$CRITICAL_COUNT" -gt 0 ]; then
        STATUS="❌ QUARANTINED"
    else
        STATUS="✅ PASSED"
    fi
    
    echo "| $IMAGE | $DATE | $HIGH_COUNT | $CRITICAL_COUNT | $STATUS |" >> "$DASHBOARD_FILE"
done

echo "\nDashboard updated: $DASHBOARD_FILE"
