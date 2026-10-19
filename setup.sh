#!/usr/bin/env bash
#
# Stow-based dotfile linker/unlinker. `link` also clones the zsh plugins and
# theme and the kitty themes, and installs the Powerlevel10k fonts.
# Usage: ./setup.sh {link|unlink}

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Linux)
    PACKAGES=(zsh vim kitty)
    ;;
  Darwin)
    PACKAGES=(zsh vim kitty)
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
        sudo pacman -S --needed stow
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

require_commands() {
  local cmd missing=()
  for cmd in "$@"; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Missing required commands: ${missing[*]}" >&2
    echo "Install them and run this script again." >&2
    exit 1
  fi
}

# Plugins and themes are not tracked in git; clone them on each machine.
# An existing directory is left untouched, so re-running is safe.
clone_if_missing() {
  local url="$1" dest="$2"

  if [[ -d "$dest" ]]; then
    echo "Already present, skipping: $dest"
    return
  fi

  git clone --depth=1 "$url" "$dest"
}

install_zsh_plugins() {
  local plugins_dir="$HOME/.config/zsh/plugins"

  clone_if_missing https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$plugins_dir/fast-syntax-highlighting"
  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "$plugins_dir/zsh-autosuggestions"
  clone_if_missing https://github.com/zsh-users/zsh-completions.git "$plugins_dir/zsh-completions"
}

install_zsh_theme() {
  clone_if_missing https://github.com/romkatv/powerlevel10k.git "$HOME/.config/zsh/themes/p10k/powerlevel10k"
}

# kitty.conf includes its theme from ./kitty-themes/themes/
install_kitty_themes() {
  clone_if_missing https://github.com/dexpota/kitty-themes.git "$HOME/.config/kitty/kitty-themes"
}

# Installs the fonts for the current user only (no sudo). The per-user font
# directory works on any Linux desktop (fontconfig) and on macOS.
install_p10k_fonts() {
  local fonts_dir font installed=0

  case "$(uname -s)" in
    Linux)
      fonts_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
      ;;
    Darwin)
      fonts_dir="$HOME/Library/Fonts"
      ;;
  esac
  mkdir -p "$fonts_dir"

  for font in "MesloLGS NF Regular.ttf" "MesloLGS NF Bold.ttf" "MesloLGS NF Italic.ttf" "MesloLGS NF Bold Italic.ttf"; do
    if [[ -f "$fonts_dir/$font" ]]; then
      echo "Already present, skipping: $fonts_dir/$font"
      continue
    fi

    echo "Installing $font into $fonts_dir..."
    curl -fsSL -o "$fonts_dir/$font.part" "https://github.com/romkatv/powerlevel10k-media/raw/master/${font// /%20}"
    mv "$fonts_dir/$font.part" "$fonts_dir/$font"
    installed=1
  done

  # macOS picks up new fonts by itself; on Linux refresh the fontconfig cache.
  if [[ $installed -eq 1 ]] && command -v fc-cache &>/dev/null; then
    fc-cache -f "$fonts_dir"
  fi
}

# Terminal emulators each store their font setting differently, so this part
# stays manual.
print_font_instructions() {
  cat <<EOF

Done. One manual step left: set "MesloLGS NF" as the font of your terminal
emulator, then open a new terminal. Instructions per terminal:
  https://github.com/romkatv/powerlevel10k#manual-font-installation
EOF
}

usage() {
  echo "Usage: ./setup.sh {link|unlink}" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

case "$1" in
  link)
    require_commands git curl
    ensure_stow_installed
    # Without a real ~/.config, stow would symlink the whole directory into
    # the repo and every app writing there would write into the repo.
    mkdir -p "$HOME/.config"
    stow -v -t "$HOME" -d "$REPO_DIR" "${PACKAGES[@]}"
    install_zsh_plugins
    install_zsh_theme
    install_kitty_themes
    install_p10k_fonts
    print_font_instructions
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
