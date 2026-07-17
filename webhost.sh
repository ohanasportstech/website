#!/bin/bash
PORT=8080
TURNSTILE_SITE_KEY="1x00000000000000000000AA"

if [ "$1" = "local" ]; then
  SUPABASE_ENV="local"
  SUPABASE_URL="http://localhost:54321"
  SUPABASE_PUB_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
else
  SUPABASE_ENV="staging"
  SUPABASE_URL="https://kawtsuhiogeszsvgyyld.supabase.co"
  SUPABASE_PUB_KEY="sb_publishable_yBAZIbXqjquvOegsVG85tg_6SXCqxm4"
fi

flutter run -d web-server --web-port "$PORT" --web-hostname 0.0.0.0 \
  --dart-define=SUPABASE_ENV="$SUPABASE_ENV" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_PUB_KEY="$SUPABASE_PUB_KEY" \
  --dart-define=TURNSTILE_SITE_KEY="$TURNSTILE_SITE_KEY"
