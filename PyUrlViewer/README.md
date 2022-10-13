# PyUrlViewer

This tiny applet will run a HTTP server on port 8080 with a single purpose: serve the contents of the URL passed to it.

## Endpoints

- `/healthcheck` - Returns "I'm alive!" with response code 200.
- `/?url=http://some.url` - Returns the contents of the URL provided.

## Get started

```sh
docker build . -t pyurlviewer
docker run --rm -p 8080:8080 --name pyurlviewer pyurlviewer
```
