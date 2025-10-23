#!/bin/bash
set -e  # Exit on error

# Build for production
echo "Building web app..."
flutter build web --release --base-href /

# Deploy to Cloudflare Pages
echo "Deploying to Cloudflare Pages..."
npx wrangler pages deploy build/web --project-name=ohanasports

echo "Deployment successful!"
echo "Your site is available at: https://ohanasports.pages.dev"
