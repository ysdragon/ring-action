#!/bin/bash

# Install Ring packages if specified
if [ "$RING_PACKAGES" != "" ]; then
    # Parse package list into array
    IFS=' ' read -r -a words <<< "$RING_PACKAGES"
    
    declare -a packages
    i=0
    n_words=${#words[@]}
    while [ $i -lt $n_words ]; do
        # Handle "package from user" format
        if [ $((i + 2)) -lt $n_words ] && [ "${words[$i+1]}" = "from" ]; then
            packages+=("${words[$i]} from ${words[$i+2]}")
            i=$((i + 3))
        else
            # Single package name
            packages+=("${words[$i]}")
            i=$((i + 1))
        fi
    done

    # Install each package
    for package in "${packages[@]}"; do
        ringpm install $package
    done
fi

# Build executable if requested
if [ "$OUTPUT_EXE" = "true" ]; then
    # Create executable from Ring source
    SCRIPT_DIR=$(dirname "$FILE")
    SCRIPT_BASE=$(basename "$FILE")
    
    pushd "$SCRIPT_DIR" > /dev/null
    ring2exe $ARGS "$SCRIPT_BASE"
    popd > /dev/null
else
    # Run Ring script directly
    SCRIPT_DIR=$(dirname "$FILE")
    SCRIPT_BASE=$(basename "$FILE")

    pushd "$SCRIPT_DIR" > /dev/null
    ring $ARGS "$SCRIPT_BASE"
    popd > /dev/null
    
    # Exit with error if Ring reported any issues
    if [[ "$output" == *"Error"* ]]; then
        exit 1
    fi
fi
