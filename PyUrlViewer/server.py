"""PyUrlViewer"""

from http.server import BaseHTTPRequestHandler, HTTPServer
from socketserver import ThreadingMixIn
from urllib.parse import parse_qs, urlparse
from urllib.request import Request, urlopen

HOST_NAME = "0.0.0.0"
SERVER_PORT = 8080

class HtmlViewer(BaseHTTPRequestHandler):
    """RequestHandler class"""

    def do_GET(self):
        """Handle GET requests"""

        # Handle healthcheck
        if self.path == "/healthcheck":
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(bytes("I'm alive!", encoding="utf-8"))
            return

        # Parse request
        request_components = parse_qs(urlparse(self.path).query)

        if "url" in request_components:
            requested_url = request_components["url"][0]

            # Get request contents
            req = Request(
                url=requested_url,
                headers={"User-Agent": "Mozilla/5.0"}
            )
            with urlopen(req) as content:
                requested_content = content.read()

            # Send contents
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(requested_content)

        else:
            self.send_error(404)

class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""

if __name__ == "__main__":
    web_server = ThreadedHTTPServer((HOST_NAME, SERVER_PORT), HtmlViewer)
    print(f"Server started: http://{HOST_NAME}:{SERVER_PORT}")

    try:
        web_server.serve_forever()
    except KeyboardInterrupt:
        pass

    web_server.server_close()
    print("Server stopped.")
