FUNCTION quarantine_run(image_name):
    
    // Initialize configuration
    SET audit_directory = user_home_directory + "/.quarantine_audit"
    CREATE audit_directory if not exists
    
    // Validate input
    IF image_name is empty:
        PRINT "Usage: ./quarantine-run.sh <image_name:tag>"
        EXIT with error code 1
    END IF
    
    // Phase 1: Pull Docker Image
    PRINT "[*] Validating Registry and Pulling Image: " + image_name
    EXECUTE docker pull with image_name
    
    // Phase 2: Generate Report Path
    SET sanitized_name = REPLACE(image_name, ['/', ':'], '_')
    SET report_file = audit_directory + "/" + sanitized_name + "-report.json"
    
    // Phase 3: Security Scanning
    PRINT "[*] Engaging Trivy. Scanning for HIGH and CRITICAL vulnerabilities..."
    EXECUTE trivy image scan with:
        - severity filter: HIGH, CRITICAL
        - exit on vulnerabilities: true (exit code 1)
        - output format: JSON
        - output destination: report_file
        - verbosity: quiet mode
        - target: image_name
    
    STORE exit_code from trivy scan
    
    // Phase 4: Decision Logic
    IF exit_code is NOT 0 (vulnerabilities detected):
        // Quarantine Path
        PRINT "[!] ALERT: Security Threshold Breached."
        PRINT "[!] Image " + image_name + " contains HIGH/CRITICAL vulnerabilities."
        PRINT "[!] Action: QUARANTINED. Execution blocked."
        PRINT "[!] Audit log saved to: " + report_file
        
        // Enforce Quarantine
        EXECUTE docker rmi --force image_name (suppress output)
        
        EXIT with error code 1
    
    ELSE (no critical vulnerabilities):
        // Safe Execution Path
        PRINT "[+] Security Scan Passed. No critical vulnerabilities detected."
        PRINT "[*] Promoting to Runtime..."
        
        EXECUTE docker run with:
            - interactive mode: true
            - terminal allocation: true
            - auto-remove after execution: true
            - image: image_name
    
    END IF

END FUNCTION