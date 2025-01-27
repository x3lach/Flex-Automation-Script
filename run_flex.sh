#!/bin/bash

set -e  # Exit immediately if any command fails

# Color codes for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error handling function
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

echo -e "${YELLOW}=== Flex Automation Script ===${NC}"

# Get Flex file path
read -p "Enter path to your Flex file (.l): " flex_path

flex_path="${flex_path/#\~/$HOME}"
flex_path="${flex_path//\$HOME/$HOME}"
flex_path=$(realpath -m "$flex_path")  # Resolve relative paths

# Validate path
echo -e "\n${YELLOW}[1/4] Validating input...${NC}"

if [[ "$flex_path" != *.l ]]; then
    error_exit "Not a Flex file (.l extension required)"
fi

if [ ! -f "$flex_path" ]; then
    error_exit "File not found: $flex_path"
fi

# Extract file components
flex_dir=$(dirname "$flex_path")
flex_file=$(basename "$flex_path")
target_name=$(basename "$flex_file" .l)

# Show file information
echo -e "${GREEN}✓ Valid Flex file detected${NC}"
echo -e " Directory: $flex_dir"
echo -e " Filename: $flex_file"
echo -e " Target: $target_name"

# Generate C code
echo -e "\n${YELLOW}[2/4] Generating C code...${NC}"
(cd "$flex_dir" && flex -o "lex.yy.c" "$flex_file") || error_exit "Flex generation failed"

# Verify C file
if [ ! -f "$flex_dir/lex.yy.c" ]; then
    error_exit "C source file not generated"
fi

# Compile executable
echo -e "\n${YELLOW}[3/4] Compiling program...${NC}"
(cd "$flex_dir" && gcc -o "$target_name" lex.yy.c -lfl) || error_exit "Compilation failed"

# Verify binary
if [ ! -f "$flex_dir/$target_name" ]; then
    error_exit "Executable not created: $target_name"
fi

# Run program
echo -e "\n${YELLOW}[4/4] Running program...${NC}"
echo -e "${GREEN}═════════ PROGRAM OUTPUT ══════════${NC}"
(cd "$flex_dir" && ./"$target_name")
echo -e "${GREEN}═════════ END OF OUTPUT ══════════${NC}"

# Success message
echo -e "\n${GREEN}✔ Successfully processed $flex_file${NC}"
exit 0