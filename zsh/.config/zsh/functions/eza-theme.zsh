# ----------------------------------------------------------------------------
# Function: eza-theme
#
# Description:
#   Switches the eza color theme by pointing $EZA_CONFIG_DIR/theme.yml to one
#   of the themes from https://github.com/eza-community/eza-themes, which
#   setup.sh clones into $EZA_CONFIG_DIR/eza-themes.
#
# Usage:
#   eza-theme          # show the current theme and list the available ones
#   eza-theme <name>   # select a theme, e.g. `eza-theme rose-pine-moon`
#
# Completion:
#   Theme names complete with <Tab>.
# ----------------------------------------------------------------------------
eza-theme() {
  local eza_dir="${EZA_CONFIG_DIR:-$HOME/.config/eza}"
  local themes_dir="$eza_dir/eza-themes/themes"
  local themes_repo="https://github.com/eza-community/eza-themes"

  if [[ ! -d "$themes_dir" ]]; then
    echo "eza themes not found in $themes_dir." >&2
    echo "Run ./setup.sh link from the dotfiles repo to clone them." >&2
    return 1
  fi

  if [[ -z "$1" ]]; then
    local current="none"
    if [[ -L "$eza_dir/theme.yml" ]]; then
      current="$(readlink "$eza_dir/theme.yml")"
      current="${current:t:r}"
    fi
    local -a themes=("$themes_dir"/*.yml(N:t:r))
    echo "Current theme: $current"
    echo "Available themes:"
    printf '  %s\n' "${themes[@]}"
    echo "Usage: eza-theme <name>"
    return 0
  fi

  if [[ "$1" == */* || ! -f "$themes_dir/$1.yml" ]]; then
    echo "Theme '$1' not found in $themes_dir." >&2
    echo "Check that it exists in $themes_repo (themes/ folder)." >&2
    echo "If it was added recently, update your local copy with:" >&2
    echo "  git -C \"$eza_dir/eza-themes\" pull" >&2
    return 1
  fi

  ln -sf "eza-themes/themes/$1.yml" "$eza_dir/theme.yml"
  echo "eza theme set to '$1'."
  echo "Browse more themes at $themes_repo"
}

_eza-theme() {
  local themes_dir="${EZA_CONFIG_DIR:-$HOME/.config/eza}/eza-themes/themes"
  compadd -- "$themes_dir"/*.yml(N:t:r)
}
compdef _eza-theme eza-theme
