#!/bin/bash

cd /Users/batume/Documents/R/GAL_git || exit 1
git config --global http.postBuffer 1572864000

# Set SSH if needed
git remote set-url origin git@github.com:aobatume/gal.git

# Reset any staged files
git reset

# Exclude prep and .git folders
items=$(ls -A | grep -v '^prep$' | grep -v '^\.git$' | grep -v 'push_chunks')

for item in $items; do
    echo "Adding and pushing $item..."

    git add "$item"
    git commit -m "Add $item"
    
    echo "Pushing $item..."
    git push origin main

    if [ $? -ne 0 ]; then
        echo "⚠️ Push failed for $item. Skipping to next item..."
        git reset --soft HEAD~1
    fi
done

echo "✅ All done pushing in smaller chunks!"
