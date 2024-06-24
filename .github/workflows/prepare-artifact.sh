#!/bin/bash

# Get inputs from workflow
artifact_name="$1"
excluded_folder="$2"
rename_folder="${3:-}"  # Optional rename parameter (default empty)

# Create temporary directory
temp_dir=$(mktemp -d)

# Copy all files except excluded folder
rsync -av --exclude="$excluded_folder" ./* "$temp_dir/"

# Optional renaming (if provided)
if [[ ! -z "$rename_folder" ]]; then
  mv "$temp_dir/$rename_folder" "$temp_dir/$(cut -d: -f2 <<< "$rename_folder")"
fi

# Upload the prepared directory (no compression)
mv "$temp_dir" "$artifact_name"  # Rename temporary directory to final artifact name

# Set output for workflow step
echo "artifact_path=$artifact_name"  # Output variable for artifact path
