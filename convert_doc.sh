#!/bin/bash

# Check if exactly 3 arguments were provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <Source File> <Target Directory> <Format (typ|tex)>"
    exit 1
fi

# 1. Store absolute paths (important because we will change directories soon)
SOURCE_FILE=$(realpath "$1")
OUTPUT_ROOT=$(realpath "$2")
SHORT_FORMAT="$3"

# Extract filename and document name (without extension)
FILENAME=$(basename "$SOURCE_FILE")
DOC_NAME="${FILENAME%.*}"

# Translate target format for Pandoc
if [ "$SHORT_FORMAT" == "typ" ]; then
    PANDOC_TO="typst"
elif [ "$SHORT_FORMAT" == "tex" ]; then
    PANDOC_TO="latex"
else
    echo "Error: Format must be 'typ' or 'tex'."
    exit 1
fi

# 2. Create the target directory
TARGET_DIR="$OUTPUT_ROOT/$DOC_NAME"
mkdir -p "$TARGET_DIR"

echo "--------------------------------------------------"
echo "File:    $DOC_NAME"
echo "Target:  $TARGET_DIR"
echo "--------------------------------------------------"

# 3. The trick: Change into the target directory!
# This forces Pandoc to write relative paths ("media/...") instead of absolute paths ("/home/...")
cd "$TARGET_DIR" || exit

# 4. Run Pandoc
# We use the absolute path ($SOURCE_FILE) for the input,
# but since we are in the target directory, the output and media folder land here.
pandoc "$SOURCE_FILE" \
    -t "$PANDOC_TO" \
    -s \
    --extract-media="media" \
    -o "$DOC_NAME.$SHORT_FORMAT"

# Final status message
if [ -f "$DOC_NAME.$SHORT_FORMAT" ]; then
    echo "DONE! ✅"
    echo "File:    $TARGET_DIR/$DOC_NAME.$SHORT_FORMAT"
    echo "Images:  $TARGET_DIR/media/"
else
    echo "ERROR: The file was not created."
fi
