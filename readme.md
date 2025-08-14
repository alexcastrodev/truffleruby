# Truffleruby Base Container

A base Docker container for TruffleRuby, built on Oracle Linux 10 with GraalVM 21.

## 🚀 Quick Start

To build the Docker image, run:

```bash
docker buildx build --platform linux/arm64 -t lekito/truffleruby:latest .
```

If you want other platforms, you can specify them using the `--platform` flag.

use in your Dockerfile:

```dockerfile
FROM lekito/truffleruby:latest

# Your application code here
```

## Using the Image

This image is only local, if you want to use it somewhere else, you can push it to a registry