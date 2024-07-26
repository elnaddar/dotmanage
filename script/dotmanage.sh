#!/bin/bash

# Get the directory of the script
SCRIPT_DIR=$(dirname "$0")

# Check if current directory contains a.csproj file
if [ -f *.csproj ]; then
  :
else
  echo "Error: No.csproj file found in the current directory."
  exit 1
fi

# Main script logic
case "$1" in
    create)
        shift
        "$SCRIPT_DIR/src/create.sh" "$@"
        ;;
    *)
        echo "Unknown command: $1"
        exit 1
        ;;
esac