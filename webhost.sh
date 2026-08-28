#!/bin/bash
PORT=8080
TURNSTILE_SITE_KEY="1x00000000000000000000AA"

if [ "$1" = "local" ]; then
  SUPABASE_ENV="local"
  # Load the current local Supabase credentials when the stack is running.
  # Falls back to the default demo key if supabase status is unavailable.
  STATUS_ENV="$(supabase status -o env 2>/dev/null || true)"
  SUPABASE_URL="$(printf '%s\n' "$STATUS_ENV" | grep '^API_URL=' | cut -d= -f2- | tr -d '"' || true)"
  SUPABASE_URL="${SUPABASE_URL:-http://127.0.0.1:54321}"
  SUPABASE_PUB_KEY="$(printf '%s\n' "$STATUS_ENV" | grep '^PUBLISHABLE_KEY=' | cut -d= -f2- | tr -d '"' || true)"
  SUPABASE_PUB_KEY="${SUPABASE_PUB_KEY:-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0}"
else
  SUPABASE_ENV="staging"
  SUPABASE_URL="https://kawtsuhiogeszsvgyyld.supabase.co"
  SUPABASE_PUB_KEY="sb_publishable_yBAZIbXqjquvOegsVG85tg_6SXCqxm4"
fi

MODE="${2:-release}"
if [ "$MODE" = "debug" ]; then
  flutter run -d web-server --web-port "$PORT" --web-hostname 0.0.0.0 --dart-define=SUPABASE_ENV="$SUPABASE_ENV" --dart-define=SUPABASE_URL="$SUPABASE_URL" --dart-define=SUPABASE_PUB_KEY="$SUPABASE_PUB_KEY" --dart-define=TURNSTILE_SITE_KEY="$TURNSTILE_SITE_KEY"
else
  flutter build web --release --base-href / --dart-define=SUPABASE_ENV="$SUPABASE_ENV" --dart-define=SUPABASE_URL="$SUPABASE_URL" --dart-define=SUPABASE_PUB_KEY="$SUPABASE_PUB_KEY" --dart-define=TURNSTILE_SITE_KEY="$TURNSTILE_SITE_KEY"
  python3 -c 'import http.server, os, socketserver, sys, urllib.parse
class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def send_head(self):
        path = self.translate_path(urllib.parse.urlsplit(self.path).path)
        if not os.path.exists(path):
            self.path = "/index.html"
        return super().send_head()
handler = lambda *args, **kwargs: SPAHandler(*args, directory="build/web", **kwargs)
with socketserver.TCPServer(("0.0.0.0", int(sys.argv[1])), handler) as server:
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass' "$PORT"
fi
