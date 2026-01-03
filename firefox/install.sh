#!/bin/bash

PROFILES_DIR="$HOME/Library/Application Support/Firefox/Profiles"

found=false

for PROFILE_DIR in "$PROFILES_DIR"/*; do
    [ -d "$PROFILE_DIR" ] || continue

    found=true
    echo "Installing config into: $PROFILE_DIR"

    cp -r user.js "$PROFILE_DIR/"
    cp -r chrome/ "$PROFILE_DIR/"
done

if [ "$found" = false ]; then
    echo "Error: Firefox profiles not found!"
    exit 1
fi

echo "Installed into all profiles."
