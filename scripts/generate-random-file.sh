#!/bin/bash
# =============================================================================
# generate_random_file.sh
# Generates a file filled with random text at a user-specified size
# =============================================================================

# -- Prompt user for filename --
read -p "Enter the desired filename: " filename

# -- Validate filename is not empty --
if [[ -z "$filename" ]]; then
    echo "Error: Filename cannot be empty."
    exit 1
fi

# -- Check if file already exists to avoid accidental overwrite --
if [[ -f "$filename" ]]; then
    read -p "File '$filename' already exists. Overwrite? (y/n): " overwrite
    if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# -- Prompt user for file size in kilobytes --
read -p "Enter desired file size in kilobytes (KB): " size_kb

# -- Validate that input is a positive integer --
if ! [[ "$size_kb" =~ ^[0-9]+$ ]] || [[ "$size_kb" -le 0 ]]; then
    echo "Error: Size must be a positive integer."
    exit 1
fi

# -- Generate the file using /dev/urandom, piped through base64 to make it --
# -- printable/readable text, then truncated to exact byte size with dd     --
echo "Generating '$filename' at ${size_kb}KB..."

dd if=/dev/urandom bs=1024 count="$size_kb" 2>/dev/null | \
    base64 | \
    head -c "$((size_kb * 1024))" > "$filename"

# -- Verify the file was created and report actual size --
if [[ -f "$filename" ]]; then
    actual_size=$(du -k "$filename" | cut -f1)
    echo "Done. File '$filename' created at approximately ${actual_size}KB."
else
    echo "Error: File creation failed."
    exit 1
fi
