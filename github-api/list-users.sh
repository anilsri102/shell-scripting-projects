#!/bin/bash

#####################################################################################################
# About: This script makes an API call to list GitHub collaborators with read access to a repo.
#
# Input: 
#   1. You must export USERNAME and TOKEN (GitHub personal access token)
#   2. You must pass exactly two arguments: <repo_owner> <repo_name>
#
# Example usage:
#   export USERNAME=your_github_username
#   export TOKEN=your_github_token
#   ./github_collaborators.sh octocat hello-world
#
# Owner: anilsri102
# Contact: anilsri102@gmail.com
#####################################################################################################

# Function to validate input arguments
function helper {
    expected_args=2
    if [ $# -ne $expected_args ]; then
        echo "Error: Invalid number of arguments."
        echo "Usage: $0 <repo_owner> <repo_name>"
        echo "Example: $0 octocat hello-world"
        exit 1
    fi
}

# Call the helper function with script arguments
helper "$@"

# Check if USERNAME and TOKEN environment variables are set
if [ -z "$USERNAME" ] || [ -z "$TOKEN" ]; then
    echo "Error: USERNAME and TOKEN environment variables must be set."
    echo "Please export them before running the script:"
    echo "  export USERNAME=your_github_username"
    echo "  export TOKEN=your_github_token"
    exit 1
fi

# GitHub API URL
API_URL="https://api.github.com"

# Repository info from script arguments
REPO_OWNER=$1
REPO_NAME=$2

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"

    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# Main logic
echo "Fetching collaborators with read access for ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
