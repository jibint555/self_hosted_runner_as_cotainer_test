#!/bin/bash
set -e

RUNNER_HOME=/home/new-runner

# Ensure runner directories exist and are writable
mkdir -p "$RUNNER_HOME/_work" "$RUNNER_HOME/_diag"
chmod 755 "$RUNNER_HOME/_work" "$RUNNER_HOME/_diag"

# Optional: Docker group setup
if [ -n "$DOCKER_GID" ]; then
  sudo groupadd -g $DOCKER_GID docker || true
  sudo usermod -aG docker new-runner || true
fi

# Register runner
./config.sh --url https://github.com/jibint555/aws_cdk_projects \
  --token ${RUNNER_TOKEN} \
  --name "test-runner" \
  --labels "gibin_runner" \
  --work _work \
  --unattended \
  --replace

# Start runner
exec ./run.sh
