#!/bin/sh

# Define registration URL
registration_url="https://api.github.com/orgs/osherlevi7/actions/runners/registration-token"

# Logging functions for better readability
log_info() {
    echo "INFO: $1"
}

log_error() {
    echo "ERROR: $1" >&2
}

# Exit the script with an error message
exit_with_error() {
    log_error "$1"
    exit 1
}

# Fetch registration token from GitHub API
log_info "Requesting registration URL at '${registration_url}'"
payload=$(curl -sX POST -H "Authorization: token ${GITHUB_PERSONAL_TOKEN}" "${registration_url}")

if [ -z "$payload" ]; then
    exit_with_error "Failed to get payload from GitHub API."
fi

RUNNER_TOKEN=$(echo "$payload" | jq .token --raw-output)

if [ -z "$RUNNER_TOKEN" ]; then
    exit_with_error "Failed to extract runner token from the payload."
fi

log_info "Runner token received successfully."

# Configure the GitHub Actions Runner
./config.sh \
    --name "gh-runner" \
    --token "${RUNNER_TOKEN}" \
    --labels "k8s" \
    --runnergroup "k8s-gh-runners" \
    --url "https://github.com/${GITHUB_ORG}" \
    --work "/work" \
    --unattended \
    --replace

# Function to remove the runner
remove_runner() {
    log_info "Removing runner..."
    ./config.sh remove --unattended --token "${RUNNER_TOKEN}"
}

# Trap signals and remove runner on exit
trap 'remove_runner; exit 130' INT
trap 'remove_runner; exit 143' TERM

# Start the runner process
log_info "Starting runner..."
./run.sh "$*" &

# Wait for the runner process
wait $!