#!/usr/bin/env bash
set -euo pipefail

HUGO_VERSION="${HUGO_VERSION:-0.163.3}"

case "$(uname -s)" in
  Linux) HUGO_OS="linux" ;;
  Darwin) HUGO_OS="darwin" ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

case "$(uname -m)" in
  x86_64 | amd64) HUGO_ARCH="amd64" ;;
  arm64 | aarch64) HUGO_ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

if [ "$HUGO_OS" = "darwin" ]; then
  if ! command -v hugo >/dev/null 2>&1; then
    echo "On macOS, install Hugo Extended or add it to PATH before running this script locally." >&2
    echo "Cloudflare will run this script on Linux and download Hugo Extended automatically." >&2
    exit 1
  fi
  hugo version
  hugo --gc --minify
  exit 0
fi

HUGO_DIR=".hugo-bin"
HUGO_ARCHIVE="hugo_extended_${HUGO_VERSION}_${HUGO_OS}-${HUGO_ARCH}.tar.gz"
HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_ARCHIVE}"

mkdir -p "$HUGO_DIR"

if [ ! -x "$HUGO_DIR/hugo" ]; then
  echo "Downloading Hugo Extended ${HUGO_VERSION} for ${HUGO_OS}-${HUGO_ARCH}"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$HUGO_URL" -o "$HUGO_DIR/$HUGO_ARCHIVE"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$HUGO_DIR/$HUGO_ARCHIVE" "$HUGO_URL"
  else
    echo "Neither curl nor wget is available to download Hugo." >&2
    exit 1
  fi
  tar -xzf "$HUGO_DIR/$HUGO_ARCHIVE" -C "$HUGO_DIR" hugo
fi

"$HUGO_DIR/hugo" version
"$HUGO_DIR/hugo" --gc --minify
