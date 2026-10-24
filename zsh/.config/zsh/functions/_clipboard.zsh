# ----------------------------------------------------------------------------
# Function: _clipboard_copy
#
# Description:
#   Shared helper for pwdc and catc. Copies stdin to the clipboard, picking
#   the tool for the current session:
#     • macOS          → pbcopy (built in)
#     • Wayland        → wl-copy (wl-clipboard), or xclip through XWayland
#     • X11            → xclip
#   Status messages go to stderr, so the caller's stdout stays clean. If the
#   tool is missing, a warning names the detected session and what to install
#   for it.
#
# Usage:
#   <command> | _clipboard_copy <what>    # <what> is used in the message
#
# Example:
#   % print -rn -- "$PWD" | _clipboard_copy Path
#   ✅ Path copied to clipboard.
# ----------------------------------------------------------------------------
_clipboard_copy() {
  local what="${1:-Text}" session hint
  local -a copy_cmd

  if [[ $OSTYPE == darwin* ]]; then
    session=macOS
    hint="pbcopy should be built into macOS; check that /usr/bin is in your PATH."
    (( $+commands[pbcopy] )) && copy_cmd=(pbcopy)
  elif [[ -n $WAYLAND_DISPLAY ]]; then
    session=Wayland
    hint="Install wl-clipboard."
    if (( $+commands[wl-copy] )); then
      copy_cmd=(wl-copy)
    elif [[ -n $DISPLAY ]] && (( $+commands[xclip] )); then
      # XWayland fallback
      copy_cmd=(xclip -selection clipboard)
    fi
  elif [[ -n $DISPLAY ]]; then
    session=X11
    hint="Install xclip."
    (( $+commands[xclip] )) && copy_cmd=(xclip -selection clipboard)
  else
    session=none
    hint="No graphical session detected (SSH or TTY?), so there is no clipboard to copy to."
  fi

  if (( ! $#copy_cmd )); then
    print -u2 "⚠️  Could not copy to clipboard (session: $session)."
    print -u2 "   $hint"
    return 1
  fi

  if "${copy_cmd[@]}" 2>/dev/null; then
    print -u2 "✅ $what copied to clipboard."
  else
    print -u2 "⚠️  Could not copy to clipboard: '${copy_cmd[1]}' failed."
    return 1
  fi
}
