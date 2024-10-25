#!/bin/bash

# ORGANIZATION

# Read user and repo (a.k.a. 'organization') from file 
source /home/docker/.ORGANIZATION
# Alternatively it can be hardcoded here, e.g.:
# ORGANIZATION="GDeLaurentis/lips"

# ACCESS TOKEN

# Read the access token from a file not committed to the git
source /home/docker/.ACCESS_TOKEN
# Alternatively it can be hardcoded here
# !WARNING: DO NOT COMMIT A PLAIN TOKEN!
# ACCESS_TOKEN="******************"

# REGISTRATION TOKEN
# Obtain the REG_TOKEN via post request to the github api
if [[ $ACCESS_TOKEN = *"github_"* ]]
then
    ## If using instead fine-grained tokens:
    REG_TOKEN=$(curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)
else
    REG_TOKEN=$(curl -sX POST -H "AuthorizaTion: token ${ACCESS_TOKEN}" https://api.github.com/repos/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)
fi

# Alternatively the REG_TOKEN can be written explicitly here
# !WARNING: DO NOT COMMIT A PLAIN TOKEN!
# REG_TOKEN="**************"

# MAIN SCRIPT
cd /home/docker/actions-runner

./config.sh --url https://github.com/${ORGANIZATION} --token ${REG_TOKEN} --labels "gpu"

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
