#!/bin/bash
set -euo pipefail

# Install jq if missing
if ! command -v jq >/dev/null 2>&1; then
    echo "ℹ️ 'jq' not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

# Prompt for GitHub App ID if not set
if [[ -z "${APP_ID:-}" ]]; then
    read -p "Enter your GitHub App ID: " APP_ID
    export APP_ID
fi

# Prompt for Installation ID if not set
if [[ -z "${INSTALLATION_ID:-}" ]]; then
    read -p "Enter your GitHub App Installation ID: " INSTALLATION_ID
    export INSTALLATION_ID
fi

# Prompt for absolute path to PEM file if not set
if [[ -z "${PEM_FILE:-}" ]]; then
    read -p "Enter the absolute path to your GitHub App PEM file: " PEM_FILE
    export PEM_FILE
fi

# Validate PEM file exists
if [[ ! -f "$PEM_FILE" ]]; then
    echo "❌ PEM file not found at: $PEM_FILE"
    exit 1
fi

# Generate JWT
now=$(date +%s)
iat=$((now - 60))
exp=$((now + 600))

header=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e -A | tr -d '=' | tr '/+' '_-')
payload=$(echo -n "{\"iat\":$iat,\"exp\":$exp,\"iss\":$APP_ID}" | openssl base64 -e -A | tr -d '=' | tr '/+' '_-')
unsigned_token="$header.$payload"
signature=$(echo -n "$unsigned_token" | openssl dgst -sha256 -sign "$PEM_FILE" | openssl base64 -e -A | tr -d '=' | tr '/+' '_-')
jwt="$unsigned_token.$signature"

# Request installation access token
access_token=$(curl -s -X POST \
    -H "Authorization: Bearer $jwt" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens" \
    | jq -r .token)

if [[ -z "$access_token" || "$access_token" == "null" ]]; then
    echo "❌ Failed to fetch installation token"
    exit 1
fi

# Export token
export GITHUB_APP_TOKEN="$access_token"

echo "✅ Installation token fetched successfully"
echo "APP_ID=$APP_ID"
echo "INSTALLATION_ID=$INSTALLATION_ID"
echo "PEM_FILE=$PEM_FILE"
echo "GITHUB_APP_TOKEN=$GITHUB_APP_TOKEN"
