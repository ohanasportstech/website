#!/bin/bash
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0 \
  --dart-define=SUPABASE_ENV=staging \
  --dart-define=SUPABASE_URL="https://kawtsuhiogeszsvgyyld.supabase.co" \
  --dart-define=SUPABASE_PUB_KEY="sb_publishable_yBAZIbXqjquvOegsVG85tg_6SXCqxm4"