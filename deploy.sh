#!/bin/bash
set -e  # Exit on error

# Show help message if no project name provided
if [ -z "$1" ]; then
  echo "Error: Project name is required."
  echo ""
  echo "Usage: $0 <project-name>"
  echo ""
  echo "Available projects:"
  echo "  ohanasports                   - Production (ohanasports.net)"
  echo "  ohanasports-staging           - Staging (ohanasports-staging.pages.dev)"
  echo ""
  echo "Examples:"
  echo "  $0 ohanasports             # Deploy to production"
  echo "  $0 ohanasports-staging     # Deploy to staging"
  echo ""
  exit 1
fi

PROJECT_NAME="$1"

# Turnstile site key (public, client-side). Override via env var if needed.
TURNSTILE_SITE_KEY="${TURNSTILE_SITE_KEY:-0x4AAAAAAD3OdKzhIjhOpp0n}"

# Determine Supabase environment based on project name
if [ "$PROJECT_NAME" = "ohanasports" ]; then
  SUPABASE_ENV="production"
else
  SUPABASE_ENV="staging"
fi

echo "Building web app for project: $PROJECT_NAME (Supabase env: $SUPABASE_ENV)..."

if [ "$SUPABASE_ENV" = "production" ]; then
  # Production credentials are hardcoded in lib/main.dart; only the env flag is needed.
  flutter build web --release --base-href / \
    --dart-define=SUPABASE_ENV="$SUPABASE_ENV" \
    --dart-define=TURNSTILE_SITE_KEY="$TURNSTILE_SITE_KEY"
else
  # Staging credentials are no longer in source; pass them via dart-define.
  flutter build web --release --base-href / \
    --dart-define=SUPABASE_ENV="$SUPABASE_ENV" \
    --dart-define=SUPABASE_URL="https://kawtsuhiogeszsvgyyld.supabase.co" \
    --dart-define=SUPABASE_PUB_KEY="sb_publishable_yBAZIbXqjquvOegsVG85tg_6SXCqxm4" \
    --dart-define=TURNSTILE_SITE_KEY="$TURNSTILE_SITE_KEY"
fi

echo "Deploying to Cloudflare Pages..."
npx wrangler pages deploy build/web --project-name="$PROJECT_NAME"

echo "Deployment successful!"
echo "Your site is available at: https://${PROJECT_NAME}.pages.dev"
