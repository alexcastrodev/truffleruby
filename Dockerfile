# syntax=docker/dockerfile:1.7
################################################################################
# Base image: Oracle Linux 10 + GraalVM (JDK 21) + TruffleRuby Community
# This image is meant to be used as a foundation for other Docker builds.
################################################################################
FROM oraclelinux:10

## ------------------------------ OCI Metadata ------------------------------- ##
LABEL org.opencontainers.image.title="truffleruby" \
      org.opencontainers.image.description="Base image with Oracle Linux 10, GraalVM 21 and TruffleRuby Community" \
      org.opencontainers.image.vendor="Alexandro castro" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/alexcastrodev/truffleruby" \
      org.opencontainers.image.version="0.1.0"

## ------------------------------- Build args -------------------------------- ##
# TARGETARCH is automatically provided by buildx for multi-arch builds
ARG TARGETOS
ARG TARGETARCH

# Versions
ARG GRAALVM_VERSION=21.0.1
ARG GRAALVM_BUILD_SUFFIX=12.1
ARG TRUFFLERUBY_VERSION=24.1.1

## ------------------------- Environment & Locale ---------------------------- ##
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en

## ------------------------ Install base dependencies ------------------------ ##
# - Enable developer repo + codeready builder for headers and -devel packages
# - Install common build tools for Ruby native extensions
RUN set -euxo pipefail \
 && dnf -y update \
 && dnf -y install oraclelinux-developer-release-el10 \
 && dnf config-manager --enable ol10_codeready_builder \
 && dnf -y install \
      dnf-plugins-core \
      curl \
      ca-certificates \
      tar gzip bzip2 xz \
      file which findutils \
      git \
      hostname \
      procps-ng \
      gcc-c++ make \
      libpq-devel \
      libyaml-devel \
      zlib zlib-devel \
      lz4 lz4-devel \
      openssl openssl-devel \
 && update-ca-trust \
 && dnf clean all \
 && rm -rf /var/cache/dnf

ENV JAVA_HOME=/opt/graalvm
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN set -euxo pipefail; \
    case "${TARGETARCH:-amd64}" in \
      amd64|x86_64) GRAAL_ARCH="x64" ;; \
      arm64|aarch64) GRAAL_ARCH="aarch64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    GRAAL_TGZ="graalvm-community-jdk-${GRAALVM_VERSION}_linux-${GRAAL_ARCH}_bin.tar.gz"; \
    GRAAL_URL="https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${GRAALVM_VERSION}/${GRAAL_TGZ}"; \
    curl --fail --location --retry 3 "${GRAAL_URL}" -o /tmp/graalvm.tgz; \
    mkdir -p /opt && tar -xzf /tmp/graalvm.tgz -C /opt; \
    mv /opt/graalvm-community-openjdk-${GRAALVM_VERSION}+${GRAALVM_BUILD_SUFFIX} "${JAVA_HOME}"; \
    rm /tmp/graalvm.tgz

ENV RBENV_ROOT=/opt/rbenv
ENV PATH=$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH

RUN git clone https://github.com/rbenv/rbenv.git $RBENV_ROOT \
 && mkdir -p "$RBENV_ROOT"/plugins \
 && git clone https://github.com/rbenv/ruby-build.git "$RBENV_ROOT"/plugins/ruby-build

RUN echo 'export RBENV_ROOT=/opt/rbenv' >> /etc/bash.bashrc \
 && echo 'export PATH=$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH' >> /etc/bash.bashrc \
 && echo 'eval "$(rbenv init - bash)"' >> /etc/bash.bashrc
