#!/bin/bash
set -e  # Exit on error

# Build for production
echo "Building web app..."
flutter build web --release

# Create gh-pages directory if it doesn't exist
mkdir -p build/gh-pages

# Copy web build files
echo "Copying build files..."
cp -R build/web/* build/gh-pages/

# Deploy to GitHub Pages
cd build/gh-pages
git init
git add -A
git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M')"
git branch -M gh-pages
git remote add origin https://github.com/ohanasportstech/website.git
git push -f origin gh-pages

echo "Deployment successful!"
