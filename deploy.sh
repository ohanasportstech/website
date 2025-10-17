#!/bin/bash
set -e  # Exit on error

# Build for production
echo "Building web app..."
flutter build web --release

# Create gh-pages directory if it doesn't exist
echo "Preparing deployment directory..."
rm -rf build/gh-pages
mkdir -p build/gh-pages

# Copy web build files
echo "Copying build files..."
cp -R build/web/* build/gh-pages/

# Deploy to GitHub Pages
echo "Deploying to GitHub Pages..."
cd build/gh-pages
git init
git add -A
git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M')"
git branch -M gh-pages
git remote add origin https://github.com/ohanasportstech/website.git
git push -f origin gh-pages

# Return to the original directory and branch
cd ../..
echo "Deployment successful!"
echo "Your site is available at: https://ohanasportstech.github.io/website/"
