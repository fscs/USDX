#!/usr/bin/env python3
# ------------------------------------------------------------
# demo_server.py
#   * GET  /nextsong   →  "Super Trouper"
#   * POST /queuesong  →  prints the posted payload, replies JSON
# ------------------------------------------------------------

import json
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs


HOST = "127.0.0.1"
PORT = 8080


class Handler(BaseHTTPRequestHandler):
    # -----------------------------------------------------------------
    # Helper: write a plain‑text response
    # -----------------------------------------------------------------
    def _send_text(self, text: str, code: int = 200):
        self.send_response(code)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(text.encode("utf-8"))))
        self.end_headers()
        self.wfile.write(text.encode("utf-8"))

    # -----------------------------------------------------------------
    # Helper: write a JSON response
    # -----------------------------------------------------------------
    def _send_json(self, payload: dict, code: int = 200):
        data = json.dumps(payload).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    # -----------------------------------------------------------------
    # GET handler
    # -----------------------------------------------------------------
    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/nextsong":
            # The answer you wanted – plain text, no JSON wrapper.
            self._send_text("Super Trouper")
        else:
            # Anything else is 404
            self._send_text("Not Found", code=404)

    # -----------------------------------------------------------------
    # POST handler
    # -----------------------------------------------------------------
    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path != "/queuesong":
            self._send_text("Not Found", code=404)
            return

        # -------------------------------------------------------------
        # 1️⃣  Read the body (respect Content‑Length)
        # -------------------------------------------------------------
        length = int(self.headers.get("Content-Length", 0))
        body_bytes = self.rfile.read(length) if length > 0 else b""

        # -------------------------------------------------------------
        # 2️⃣  Try to turn it into something printable
        # -------------------------------------------------------------
        try:
            # Prefer JSON when the client says it’s JSON
            if "application/json" in self.headers.get("Content-Type", ""):
                body = json.loads(body_bytes.decode("utf-8"))
                pretty = json.dumps(body, indent=2)
            else:
                # Fallback: just show raw bytes as utf‑8 (or hex if decode fails)
                pretty = body_bytes.decode("utf-8")
        except Exception as exc:               # malformed JSON, non‑utf‑8 …
            pretty = f"<unreadable> ({exc})"

        # -------------------------------------------------------------
        # 3️⃣  Print what we received (goes to the console where you launched the server)
        # -------------------------------------------------------------
        print("\n=== /queuesong POST received ===", file=sys.stderr)
        print(f"Headers:\n{self.headers}")
        print("Body:")
        print(pretty)
        print("=== end of request ===\n", file=sys.stderr)
        sys.stderr.flush()

        # -------------------------------------------------------------
        # 4️⃣  Reply with a tiny JSON object so the client knows we got it
        # -------------------------------------------------------------
        response = {"status": "ok", "received_bytes": len(body_bytes)}
        self._send_json(response)

    # -----------------------------------------------------------------
    # Suppress the default logging that prints every request line.
    # (We already print what we need in do_POST.)
    # -----------------------------------------------------------------
    def log_message(self, format, *args):
        # Uncomment the line below if you *do* want the built‑in log.
        # sys.stderr.write("%s - - [%s] %s\n" % (self.client_address[0],
        #                     self.log_date_time_string(),
        #                     format%args))
        pass


def run():
    srv = HTTPServer((HOST, PORT), Handler)
    print(f"🚀  Demo server listening on http://{HOST}:{PORT}")
    print("   * GET  /nextsong   →  \"Super Trouper\"")
    print("   * POST /queuesong  →  prints body to this console")
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        print("\n👋  Stopping server …")
        srv.server_close()


if __name__ == "__main__":
    run()
