#!/bin/bash
set -e
# Create ZIP file for SAST Scan
#zip -r project.zip . -x '*.git*'
"C:\Program Files\7-Zip\7z.exe" a -r project.zip * -x!*.git*
# Perform SAST Scan
RESPONSE=$(curl -X POST \
  -H "Client-ID: 23e4567-e89b-12d3-a456-426614174001" \
  -H "Client-Secret: 47261cbcf55a16506007c76fd964175e" \
  -F "projectZipFile=@project.zip" \
  -F "applicationId=68808d22fe11dd081171be42" \
  -F "scanName=Python SAST Scan from TeamCity" \
  -F "language=python" \
  https://appsecops-api.intruceptlabs.com/api/v1/integrations/sast-scans)
# Use Python to parse and display JSON
python - <<EOF
import json
import sys
try:
    data = json.loads('''$RESPONSE''')
    print("SAST Scan Results:")
    print(f"Can Proceed: {data.get('canProceed', 'N/A')}")
    print("\nVulnerabilities Table:")
    vulns_table = data.get('vulnsTable', 'No vulnerabilities table found')
    print(json.dumps(vulns_table, indent=2))
    
    if data.get('canProceed') == False:
        print("\nCritical vulnerabilities found. Please review the scan results.")
    else:
        print("\nNo critical vulnerabilities detected.")
except json.JSONDecodeError:
    print("Error: Invalid JSON response")
    print("Raw response:", '''$RESPONSE''')
except Exception as e:
    print(f"Error: {str(e)}")
    print("Raw response:", '''$RESPONSE''')
EOF
# Clean up
rm project.zip
# Always exit with 0 to not fail the build
exit 0
