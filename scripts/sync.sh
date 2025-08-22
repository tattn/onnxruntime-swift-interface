#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/microsoft/onnxruntime.git"
TAG="v1.17.3"
SOURCE_DIR="objectivec"
DEST_DIR="Sources/onnxruntime-swift-interface"
INCLUDE_DEST_DIR="Sources/onnxruntime-swift-interface/include"
TEMP_DIR=$(mktemp -d)

echo -e "${GREEN}Starting sync from onnxruntime ${TAG}...${NC}"

# Files to exclude
EXCLUDE_FILES=(
    "ReadMe.md"
    "format_objc.sh"
    "test"
    "docs"
    "ort_checkpoint.mm"
    "ort_checkpoint_internal.h"
    "ort_training_session_internal.h"
    "ort_training_session.mm"
    "include/ort_checkpoint.h"
    "include/ort_training_session.h"
    "include/onnxruntime_training.h"
)

# Additional header files to copy from include directory
INCLUDE_FILES=(
    "include/onnxruntime/core/session/onnxruntime_c_api.h"
    "include/onnxruntime/core/session/onnxruntime_cxx_api.h"
    "include/onnxruntime/core/session/onnxruntime_cxx_inline.h"
    "include/onnxruntime/core/session/onnxruntime_float16.h"
)

# Get the script directory (where sync.sh is located) - do this before changing directories
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Clean up function
cleanup() {
    echo -e "${YELLOW}Cleaning up temporary directory...${NC}"
    rm -rf "$TEMP_DIR"
}

# Set trap to clean up on exit
trap cleanup EXIT

# Clone the repository with specific tag and sparse checkout
echo -e "${GREEN}Cloning onnxruntime repository (tag: $TAG)...${NC}"
cd "$TEMP_DIR"
git clone --depth 1 --branch "$TAG" --single-branch --filter=blob:none --sparse "$REPO_URL" onnxruntime
cd onnxruntime
git sparse-checkout set "$SOURCE_DIR" "include/onnxruntime/core/session"

# Create destination directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/$DEST_DIR"

# Build rsync exclude arguments
RSYNC_EXCLUDES=""
for exclude in "${EXCLUDE_FILES[@]}"; do
    RSYNC_EXCLUDES="$RSYNC_EXCLUDES --exclude=$exclude"
done

# Copy files using rsync
echo -e "${GREEN}Copying files from $SOURCE_DIR to $DEST_DIR...${NC}"
echo -e "${YELLOW}Excluding: ${EXCLUDE_FILES[*]}${NC}"

rsync -av --delete $RSYNC_EXCLUDES "$TEMP_DIR/onnxruntime/$SOURCE_DIR/" "$PROJECT_ROOT/$DEST_DIR/"

# Copy additional header files
echo -e "${GREEN}Copying additional header files to $INCLUDE_DEST_DIR...${NC}"
mkdir -p "$PROJECT_ROOT/$INCLUDE_DEST_DIR"

for header_file in "${INCLUDE_FILES[@]}"; do
    if [ -f "$TEMP_DIR/onnxruntime/$header_file" ]; then
        # Get just the filename (not the path)
        filename=$(basename "$header_file")
        # Copy the file directly to the include directory
        dest_file="$PROJECT_ROOT/$INCLUDE_DEST_DIR/$filename"
        cp "$TEMP_DIR/onnxruntime/$header_file" "$dest_file"
        echo -e "${GREEN}  ✓ Copied $filename${NC}"
    else
        echo -e "${RED}  ✗ File not found: $header_file${NC}"
    fi
done

echo -e "${GREEN}✅ Sync completed successfully!${NC}"
echo -e "${GREEN}Files have been copied from onnxruntime $TAG:${NC}"
echo -e "${GREEN}  - $SOURCE_DIR → $DEST_DIR${NC}"
echo -e "${GREEN}  - Headers → $INCLUDE_DEST_DIR${NC}"
