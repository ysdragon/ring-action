#!/bin/bash

# Check if we need to switch Ring versions
if [ "$INPUT_VERSION" != "v1.23" ]; then
    echo "Switching Ring version to $INPUT_VERSION..."
    # Navigate to the ring directory
    pushd /opt/ring
    
    # Clean untracked files and directories
    echo "Cleaning untracked files..."
    git clean -xf > /dev/null 2>&1

    # Fetch only the desired version (tag or branch) with a shallow clone
    echo "Fetching version: $INPUT_VERSION..."
    if ! git fetch --depth 1 origin "$INPUT_VERSION"; then
        echo "Error: Version $INPUT_VERSION not found"
        exit 1
    fi

    # Checkout the fetched version
    echo "Checking out version: $INPUT_VERSION"
    git checkout -f FETCH_HEAD > /dev/null 2>&1

    # Check the RING_VERSION and apply patches if it's under v1.22
    version_num=$(echo "$INPUT_VERSION" | sed 's/^v//')
    if [ "$(echo "$version_num < 1.22" | bc)" -eq 1 ]; then
        echo "Applying patches for versions older than v1.22..."
        git apply /patches/ringpdfgen.patch && \
        git apply /patches/ringfastpro.patch
    fi

    # Apply necessary build modifications for the new version
    echo "Applying build modifications..."
    find . -type f -name "*.sh" -exec sed -i 's/\bsudo\b//g' {} +
    find . -type f -name "*.sh" -exec sed -i 's/-L \/usr\/lib\/i386-linux-gnu//g' {} +
    find extensions/ringqt -name "*.sh" -exec sed -i 's/\bmake\b/make -j$(nproc)/g' {} +
    rm -rf extensions/ringraylib5/src/linux_raylib-5
    rm -rf extensions/ringtilengine/linux_tilengine
    rm -rf extensions/ringlibui/linux
    sed -i 's/ -I linux_raylib-5\/include//g; s/ -L $PWD\/linux_raylib-5\/lib//g' extensions/ringraylib5/src/buildgcc.sh
    sed -i '/extensions\/ringraylib5\/src\/linux/d' bin/install.sh
    sed -i 's/ -I linux_tilengine\/include//g; s/ -L $PWD\/linux_tilengine\/lib//g' extensions/ringtilengine/buildgcc.sh
    sed -i '/extensions\/ringtilengine/d' bin/install.sh
    sed -i 's/ -I linux//g; s/ -L \$PWD\/linux//g' extensions/ringlibui/buildgcc.sh
    sed -i '/extensions\/ringlibui\/linux/d' bin/install.sh
    sed -i 's/-L \/usr\/local\/pgsql\/lib//g' extensions/ringpostgresql/buildgcc.sh

    # Build the project
    echo "Building Ring from source..."
    cd build
    if bash buildgcc.sh; then
        echo "Ring built successfully."
    else
        echo "Failed to build Ring from source."
        exit 1
    fi
    cd ../bin
    bash install.sh
    
    # Return to the previous directory
    popd
fi

# Check if the INPUT_RING_PACKAGES is not empty
if [ "$INPUT_RING_PACKAGES" != "" ]; then
    # Split the input string into an array of words
    IFS=' ' read -r -a words <<< "$INPUT_RING_PACKAGES"
    
    declare -a packages
    i=0
    n_words=${#words[@]}
    while [ $i -lt $n_words ]; do
        # Check for the pattern "<package> from <user>"
        if [ $((i + 2)) -lt $n_words ] && [ "${words[$i+1]}" = "from" ]; then
            packages+=("${words[$i]} from ${words[$i+2]}")
            i=$((i + 3))
        else
            packages+=("${words[$i]}")
            i=$((i + 1))
        fi
    done

    # Loop through each reconstructed package and install it
    for package in "${packages[@]}"; do
        echo "Installing $package..."
        ringpm install $package
    done
fi

# Check if the INPUT_OUTPUT_EXE is 'true'
if [ "$INPUT_OUTPUT_EXE" = "true" ]; then
    # Execute ring2exe with the provided arguments and input file
    SCRIPT_DIR=$(dirname "$INPUT_FILE")
    SCRIPT_BASE=$(basename "$INPUT_FILE")
    
    pushd "$SCRIPT_DIR" > /dev/null
    ring2exe $INPUT_ARGS "$SCRIPT_BASE"
    popd > /dev/null
else
    # Execute ring with the provided arguments and input file
    SCRIPT_DIR=$(dirname "$INPUT_FILE")
    SCRIPT_BASE=$(basename "$INPUT_FILE")

    pushd "$SCRIPT_DIR" > /dev/null
    ring $INPUT_ARGS "$SCRIPT_BASE"
    popd > /dev/null

    # Print the output
    echo "$output"
    
    # Check if the output contains the word "Error"
    if [[ "$output" == *"Error"* ]]; then
        exit 1
    fi
fi
