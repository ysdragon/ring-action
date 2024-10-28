#!/bin/bash

# Exit on error, print commands being executed
set -ex

# Check if we need to switch Ring versions
if [ "$INPUT_VERSION" != "v1.21.2" ]; then
    # Navigate to the ring directory
    pushd /opt/ring
    
    # Clean untracked files and directories
    git clean -xf
    
    # Fetch all remote branches and tags
    git fetch --all --tags
    
    # Reset origin/master
    git reset --hard origin/master
    
    # If INPUT_VERSION is a tag, checkout the tag
    if git rev-parse "refs/tags/$INPUT_VERSION" >/dev/null 2>&1; then
        git checkout "refs/tags/$INPUT_VERSION"
    # If INPUT_VERSION is a branch, checkout the remote branch
    elif git rev-parse "origin/$INPUT_VERSION" >/dev/null 2>&1; then
        git checkout -B "$INPUT_VERSION" "origin/$INPUT_VERSION"
    else
        echo "Error: Version $INPUT_VERSION not found"
        exit 1
    fi

    # Build the project
    cd build
    bash buildgcc.sh
    
    # Return to the previous directory
    popd
fi

# Execute ring2exe with the provided arguments and input file
ring2exe $INPUT_ARGS $INPUT_FILE