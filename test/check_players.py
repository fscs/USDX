#!/usr/bin/env python3
"""Compile and run the player-layout and queue transport checks."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class QueueHandler(BaseHTTPRequestHandler):
    events = []

    def log_message(self, *_):
        pass

    def do_GET(self):
        if self.path.startswith("/error/"):
            self.send_error(503)
            return
        if self.path.startswith("/stall/"):
            time.sleep(3)
        body = b"x" * 65537 if self.path.startswith("/oversized/") else "Björk 東京".encode()
        self.send_response(200)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        try:
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            pass

    def do_POST(self):
        length = int(self.headers["Content-Length"])
        self.events.append((self.path, json.loads(self.rfile.read(length))))
        self.send_response(200)
        self.send_header("Content-Length", "0")
        self.end_headers()


def main():
    root = Path(__file__).resolve().parent.parent
    compiler = os.environ.get("FPC", "fpc")
    server = ThreadingHTTPServer(("127.0.0.1", 0), QueueHandler)
    worker = threading.Thread(target=server.serve_forever, daemon=True)
    worker.start()
    try:
        with tempfile.TemporaryDirectory(prefix="usdx-player-checks-") as output:
            for test in ("TestPlayerLayout", "TestUltraQueue"):
                subprocess.run(
                    [compiler, "-Cr", "-Co", "-Ci", "-Sa", "-gh", f"-Fu{root / 'src/base'}",
                     f"-FU{output}", f"-FE{output}", str(root / "test" / f"{test}.pas")],
                    check=True,
                )
                command = [str(Path(output) / test)]
                if test == "TestUltraQueue":
                    command.append(f"http://127.0.0.1:{server.server_port}")
                subprocess.run(command, check=True, timeout=30)
        assert len(QueueHandler.events) == 40
        for index, (path, payload) in enumerate(QueueHandler.events):
            assert path == ("/good/startedplaying" if index % 2 == 0 else "/good/songfinished")
            assert payload == {"title": 'Björk "東京"\n\\', "artist": "Artist"}
    finally:
        server.shutdown()
        server.server_close()


if __name__ == "__main__":
    main()
