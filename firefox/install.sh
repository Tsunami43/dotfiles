#!/bin/bash

PROFILE_DIR=$(ls -d "$HOME/Library/Application Support/Firefox/Profiles/"*default-release 2>/dev/null | head -n1)

if [ -z "$PROFILE_DIR" ]; then
    echo "Error: profile Firefox not found!"
    exit 1
fi

cp -r user.js "$PROFILE_DIR/"
cp -r chrome/ "$PROFILE_DIR/"
echo "Installed.."
