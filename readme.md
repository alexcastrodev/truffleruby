# Truffleruby Base Container

A base Docker container for TruffleRuby, built on Oracle Linux 10 with GraalVM 21.

## 🚀 Quick Start

You first need to build the base image.

```bash
docker buildx build --platform linux/arm64 -t lekito/truffleruby:latest .
```

if you want JVM support, you can build the JVM variant:

```bash
docker buildx build --platform linux/arm64 -f Dockerfile.jvm -t lekito/truffleruby-jvm:latest .
```

See more in https://github.com/oracle/truffleruby

## Usage

If you want other platforms, you can specify them using the `--platform` flag.

use in your Dockerfile:

```dockerfile
FROM lekito/truffleruby:latest

# Your application code here
```

## Using the Image

This image is only local, if you want to use it somewhere else, you can push it to a registry