#!/bin/bash

# Check if input files are provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 input_file1.mp4 [input_file2.mp4 ...]"
    echo "       $0 \"*.mp4\" (to process all .mp4 files in the current directory)"
    exit 1
fi

# Process each input file
for input_file in "$@"; do
    # Skip if the file doesn't exist
    if [ ! -f "$input_file" ]; then
        echo "Warning: File '$input_file' not found, skipping..."
        continue
    fi

    # Create a temporary file for processing
    temp_file="${input_file%.*}_temp$$.mp4"
    
    echo "Processing: $input_file"
    
    # Process the video to a temporary file first
    ffmpeg -i "$input_file" \
        -an \
        -c:v libx264 -preset medium -crf 22 -profile:v high -level 4.0 -pix_fmt yuv420p \
        -vf "scale=1280:-2" -r 30 \
        -g 60 -keyint_min 60 -sc_threshold 0 \
        -movflags +faststart \
        -y \
        "$temp_file"

    if [ $? -eq 0 ]; then
        # If successful, replace the original file
        mv -f "$temp_file" "$input_file"
        echo "Successfully processed: $input_file"
    else
        echo "Error processing: $input_file"
        # Clean up temp file if it was created
        [ -f "$temp_file" ] && rm -f "$temp_file"
    fi
done