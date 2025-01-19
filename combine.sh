#!/usr/local/bin/bash
# (Make sure the shebang points to the upgraded Bash)
output_file="combined.swift.txt"

# Clear (or create) the output file
: > "$output_file"

# Declare an associative array to track processed basenames
declare -A seen_files

# Use find to list all .swift files (excluding our output file if necessary)
# and sort the results for a predictable order.
find . -type f -name "*.swift" -not -path "./$output_file" | sort | while read -r file; do
    base=$(basename "$file")
    # If this basename has already been processed, skip it
    if [[ -n "${seen_files[$base]}" ]]; then
        continue
    fi

    # Mark this basename as seen
    seen_files[$base]=1

    # Append the header and file content to the output file
    echo "===== $base =====" >> "$output_file"
    cat "$file" >> "$output_file"
    echo -e "\n\n" >> "$output_file"
done


