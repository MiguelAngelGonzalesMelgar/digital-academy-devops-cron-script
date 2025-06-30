#!/usr/bin/env bash

# Date: $(date +%Y-%m-%d)

# daily_maintenance.sh - daily maintenance Script

# Autor: Miguel Gonzales


# Variables config
LOG_FILE="/var/log/devops-logs/script.log"
WEB_URL="https://assuresoft.com"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DOWNLOAD_DIR="/var/log/devops-logs"

# Ensure echo statements and redirections are on the same line
echo "========================================" >> "$LOG_FILE"
echo "Starting daily maintenance Script: $(date)" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# 1. Check if curl installed
echo "1. Checking if curl is already installed..." >> "$LOG_FILE"
if ! command -v curl &> /dev/null; then
    echo "ERROR: curl is not installed in this Mac" >> "$LOG_FILE"
    exit 1
else
    echo "curl is already install: $(curl --version | head -n1)" >> "$LOG_FILE"
fi

# 2. Check if logs directory exists
echo "2. Checking if logs dir exist..." >> "$LOG_FILE"
if [ ! -d "$DOWNLOAD_DIR" ]; then
    echo "ERROR: directory $DOWNLOAD_DIR doesn't exists" >> "$LOG_FILE"
    echo "Please create it using: sudo mkdir -p $DOWNLOAD_DIR" >> "$LOG_FILE"
    exit 1
else
    echo "Directory $DOWNLOAD_DIR exists and is accesible" >> "$LOG_FILE"
fi

# 3. Download web page with timestamp
echo "3. Downloading..." >> "$LOG_FILE"
DOWNLOAD_FILE="${DOWNLOAD_DIR}/assuresoft_${TIMESTAMP}.html"
# Use curl to get the web page
curl_result=$(curl -s -o "$DOWNLOAD_FILE" -w "%{http_code}" "$WEB_URL" 2>> "$LOG_FILE")

# 4. Register in log
if [ "$curl_result" = "200" ]; then
    echo "✓ Downloaded successfully: $WEB_URL" >> "$LOG_FILE"
    echo "✓ File saved: $DOWNLOAD_FILE" >> "$LOG_FILE"
    echo "✓ HTTP status code: $curl_result" >> "$LOG_FILE"

    # Show downloaded file size
    # Using 'stat -f%z' for macOS (BSD stat) and 'du -b' for Linux (GNU stat alternative if stat -c%s is not available)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        file_size=$(stat -f%z "$DOWNLOAD_FILE" 2>/dev/null || echo "Size is not available")
    else
        # For Linux or other systems where stat -f%z might not work
        file_size=$(du -b "$DOWNLOAD_FILE" | awk '{print $1}' 2>/dev/null || echo "Size is not available")
    fi
    echo "✓ File size: $file_size bytes" >> "$LOG_FILE"
else
    echo "✗ An Error happened during the download: $WEB_URL" >> "$LOG_FILE"
    echo "✗ HTTP status code: $curl_result" >> "$LOG_FILE"
fi
echo "Script End: $(date)" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
exit 0
