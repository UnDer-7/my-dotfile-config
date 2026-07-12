#!/usr/bin/env bash
#
# Stow-based dotfile linker/unlinker.
# Usage: ./setup {link|unlink}

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Linux)
    PACKAGES=(zsh vim)
    ;;
  Darwin)
    PACKAGES=(zsh vim)
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

ensure_stow_installed() {
  if command -v stow &>/dev/null; then
    return
  fi

  read -r -p "stow not found. Install it now? [y/N] " reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "Aborting: stow is required to continue." >&2
    exit 1
  fi

  case "$(uname -s)" in
    Linux)
      if command -v apt-get &>/dev/null; then
        echo "stow not found, installing via apt-get, may ask for your sudo password..."
        sudo apt-get update && sudo apt-get install -y stow
      elif command -v pacman &>/dev/null; then
        echo "stow not found, installing via pacman, may ask for your sudo password..."
        sudo pacman -Sy --noconfirm stow
      elif command -v dnf &>/dev/null; then
        echo "stow not found, installing via dnf, may ask for your sudo password..."
        sudo dnf install -y stow
      else
        echo "No supported package manager found (apt-get, pacman, dnf)." >&2
        echo "Install GNU Stow manually and run this script again." >&2
        exit 1
      fi
      ;;
    Darwin)
      if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Install Homebrew first: https://brew.sh" >&2
        exit 1
      fi
      echo "stow not found, installing via brew..."
      brew install stow
      ;;
  esac
}

usage() {
  echo "Usage: ./setup {link|unlink}" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

case "$1" in
  link)
    ensure_stow_installed
    stow -v -t "$HOME" -d "$REPO_DIR" "${PACKAGES[@]}"
    ;;
  unlink)
    ensure_stow_installed
    stow -D -v -t "$HOME" -d "$REPO_DIR" "${PACKAGES[@]}"
    ;;
  *)
    usage
    exit 1
    ;;
esac
