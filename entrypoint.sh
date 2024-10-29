#!/bin/bash

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

# Check if the INPUT_RING_PACKAGES is not empty
if [ "$INPUT_RING_PACKAGES" != "" ]; then
    # Split the input string into an array of packages
    IFS=' ' read -r -a packages <<< "$INPUT_RING_PACKAGES"
    
    # Loop through each package and install it
    for package in "${packages[@]}"; do
        ringpm install "$package"
    done
fi

# Check if the INPUT_OUTPUT_EXE is 'true'
if [ "$INPUT_OUTPUT_EXE" = "true" ]; then
    # Execute ring2exe with the provided arguments and input file
    ring2exe $INPUT_ARGS $INPUT_FILE
else
    # Execute ring with the provided arguments and input file
    output=$(ring $INPUT_ARGS $INPUT_FILE)

    # Print the output
    echo "$output"
    
    # Check if the output contains the word "Error"
    if [[ "$output" == *"Error"* ]]; then
        exit 1
    fi
fi
